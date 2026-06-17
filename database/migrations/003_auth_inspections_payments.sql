-- Rentacar SaaS — Auth, Inspections, Payments, Extended RPC

-- Tenant users (RBAC)
CREATE TABLE IF NOT EXISTS tenant_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  email VARCHAR(255) NOT NULL,
  password_hash TEXT NOT NULL,
  full_name VARCHAR(255),
  role VARCHAR(50) NOT NULL DEFAULT 'staff',
  branch_id UUID REFERENCES branches(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(tenant_id, email)
);

-- Inspections & damage (operasyon)
CREATE TABLE IF NOT EXISTS vehicle_inspections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  rental_id UUID NOT NULL REFERENCES rentals(id),
  vehicle_id UUID NOT NULL REFERENCES vehicles(id),
  type VARCHAR(20) NOT NULL CHECK (type IN ('pickup', 'return')),
  km_reading INT,
  fuel_level INT CHECK (fuel_level BETWEEN 0 AND 100),
  notes TEXT,
  signature_url TEXT,
  inspected_by UUID REFERENCES tenant_users(id),
  inspected_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS damage_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  inspection_id UUID NOT NULL REFERENCES vehicle_inspections(id),
  vehicle_id UUID NOT NULL REFERENCES vehicles(id),
  part VARCHAR(50),
  damage_type VARCHAR(50),
  severity VARCHAR(20) DEFAULT 'minor',
  estimated_cost DECIMAL(12,2) DEFAULT 0,
  photo_urls JSONB DEFAULT '[]',
  is_pre_existing BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Payments (genişletilmiş)
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  rental_id UUID REFERENCES rentals(id),
  customer_id UUID NOT NULL REFERENCES customers(id),
  type VARCHAR(30) NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'TRY',
  method VARCHAR(30) DEFAULT 'card',
  status VARCHAR(20) DEFAULT 'pending',
  provider VARCHAR(50),
  provider_transaction_id VARCHAR(255),
  invoice_number VARCHAR(50),
  notes TEXT,
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  rental_id UUID REFERENCES rentals(id),
  customer_id UUID NOT NULL REFERENCES customers(id),
  invoice_number VARCHAR(50) NOT NULL,
  invoice_type VARCHAR(20) DEFAULT 'e_arsiv',
  subtotal DECIMAL(12,2) NOT NULL,
  tax_amount DECIMAL(12,2) NOT NULL,
  total_amount DECIMAL(12,2) NOT NULL,
  status VARCHAR(20) DEFAULT 'draft',
  gib_uuid VARCHAR(100),
  issued_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(tenant_id, invoice_number)
);

CREATE TABLE IF NOT EXISTS maintenance_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  vehicle_id UUID NOT NULL REFERENCES vehicles(id),
  type VARCHAR(50) DEFAULT 'periodic',
  description TEXT,
  km_at_service INT,
  cost DECIMAL(12,2) DEFAULT 0,
  service_provider VARCHAR(255),
  scheduled_at DATE,
  completed_at DATE,
  status VARCHAR(20) DEFAULT 'scheduled',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  table_name VARCHAR(100),
  record_id UUID,
  action VARCHAR(20),
  old_data JSONB,
  new_data JSONB,
  changed_by UUID,
  changed_at TIMESTAMPTZ DEFAULT now()
);

-- API views
CREATE OR REPLACE VIEW api.customers AS
SELECT
  id, tenant_id, type, first_name, last_name, company_name,
  identity_number, email, phone, birth_date,
  is_blacklisted, loyalty_points, created_at,
  trim(coalesce(first_name, '') || ' ' || coalesce(last_name, '')) AS full_name
FROM customers;

CREATE OR REPLACE VIEW api.payments AS
SELECT
  p.id, p.tenant_id, p.rental_id, p.customer_id, p.type, p.amount,
  p.currency, p.method, p.status, p.provider, p.invoice_number,
  p.paid_at, p.created_at,
  c.first_name || ' ' || c.last_name AS customer_name,
  r.rental_number
FROM payments p
LEFT JOIN customers c ON c.id = p.customer_id
LEFT JOIN rentals r ON r.id = p.rental_id;

CREATE OR REPLACE VIEW api.inspections AS
SELECT
  i.id, i.tenant_id, i.rental_id, i.vehicle_id, i.type,
  i.km_reading, i.fuel_level, i.notes, i.inspected_at,
  r.rental_number, v.plate_number, v.brand, v.model
FROM vehicle_inspections i
JOIN rentals r ON r.id = i.rental_id
JOIN vehicles v ON v.id = i.vehicle_id;

CREATE OR REPLACE VIEW api.maintenance AS
SELECT
  m.id, m.tenant_id, m.vehicle_id, m.type, m.description,
  m.km_at_service, m.cost, m.service_provider,
  m.scheduled_at, m.completed_at, m.status,
  v.plate_number, v.brand, v.model
FROM maintenance_records m
JOIN vehicles v ON v.id = m.vehicle_id;

CREATE OR REPLACE VIEW api.invoices AS
SELECT * FROM invoices;

-- Demo admin user (password: admin123 — bcrypt hash)
INSERT INTO tenant_users (id, tenant_id, email, password_hash, full_name, role) VALUES
  ('50000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'admin@premium-rent.com',
   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
   'Admin Kullanıcı',
   'tenant_owner')
ON CONFLICT DO NOTHING;

-- RPC: Create customer
CREATE OR REPLACE FUNCTION api.create_customer(
  p_tenant_id uuid,
  p_first_name text,
  p_last_name text,
  p_email text,
  p_phone text,
  p_identity_number text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
DECLARE v_id uuid;
BEGIN
  INSERT INTO customers (tenant_id, first_name, last_name, email, phone, identity_number)
  VALUES (p_tenant_id, p_first_name, p_last_name, p_email, p_phone, p_identity_number)
  RETURNING id INTO v_id;
  RETURN jsonb_build_object('id', v_id);
END;
$$;

-- RPC: Complete check-in
CREATE OR REPLACE FUNCTION api.complete_checkin(
  p_tenant_id uuid,
  p_rental_id uuid,
  p_km_reading int,
  p_fuel_level int,
  p_notes text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
DECLARE
  v_vehicle_id uuid;
  v_inspection_id uuid;
BEGIN
  SELECT vehicle_id INTO v_vehicle_id FROM rentals
  WHERE id = p_rental_id AND tenant_id = p_tenant_id;

  IF v_vehicle_id IS NULL THEN
    RAISE EXCEPTION 'rental not found';
  END IF;

  INSERT INTO vehicle_inspections (tenant_id, rental_id, vehicle_id, type, km_reading, fuel_level, notes)
  VALUES (p_tenant_id, p_rental_id, v_vehicle_id, 'pickup', p_km_reading, p_fuel_level, p_notes)
  RETURNING id INTO v_inspection_id;

  UPDATE rentals SET status = 'active', updated_at = now()
  WHERE id = p_rental_id;

  UPDATE vehicles SET status = 'rented', current_km = p_km_reading
  WHERE id = v_vehicle_id;

  RETURN jsonb_build_object('inspection_id', v_inspection_id, 'status', 'active');
END;
$$;

-- RPC: Complete check-out
CREATE OR REPLACE FUNCTION api.complete_checkout(
  p_tenant_id uuid,
  p_rental_id uuid,
  p_km_reading int,
  p_fuel_level int,
  p_damage_cost decimal DEFAULT 0,
  p_notes text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
DECLARE
  v_vehicle_id uuid;
  v_inspection_id uuid;
  v_customer_id uuid;
BEGIN
  SELECT vehicle_id, customer_id INTO v_vehicle_id, v_customer_id FROM rentals
  WHERE id = p_rental_id AND tenant_id = p_tenant_id;

  INSERT INTO vehicle_inspections (tenant_id, rental_id, vehicle_id, type, km_reading, fuel_level, notes)
  VALUES (p_tenant_id, p_rental_id, v_vehicle_id, 'return', p_km_reading, p_fuel_level, p_notes)
  RETURNING id INTO v_inspection_id;

  UPDATE rentals SET status = 'returned', updated_at = now() WHERE id = p_rental_id;
  UPDATE vehicles SET status = 'available', current_km = p_km_reading WHERE id = v_vehicle_id;

  IF p_damage_cost > 0 THEN
    INSERT INTO payments (tenant_id, rental_id, customer_id, type, amount, method, status, notes, paid_at)
    VALUES (p_tenant_id, p_rental_id, v_customer_id, 'damage', p_damage_cost, 'card', 'pending',
            'Hasar kesintisi — check-out', NULL);
  END IF;

  RETURN jsonb_build_object('inspection_id', v_inspection_id, 'status', 'returned');
END;
$$;

-- RPC: Record payment
CREATE OR REPLACE FUNCTION api.record_payment(
  p_tenant_id uuid,
  p_rental_id uuid,
  p_customer_id uuid,
  p_type text,
  p_amount decimal,
  p_method text DEFAULT 'card'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
DECLARE v_id uuid;
BEGIN
  INSERT INTO payments (tenant_id, rental_id, customer_id, type, amount, method, status, paid_at)
  VALUES (p_tenant_id, p_rental_id, p_customer_id, p_type, p_amount, p_method, 'completed', now())
  RETURNING id INTO v_id;
  RETURN jsonb_build_object('id', v_id, 'status', 'completed');
END;
$$;

-- RPC: Revenue report
CREATE OR REPLACE FUNCTION api.get_revenue_report(p_tenant_id uuid, p_days int DEFAULT 30)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
  SELECT jsonb_build_object(
    'total_revenue', coalesce(sum(total_price), 0),
    'rental_count', count(*),
    'avg_daily_rate', coalesce(avg(total_price), 0),
    'period_days', p_days
  )
  FROM rentals
  WHERE tenant_id = p_tenant_id
    AND status NOT IN ('cancelled', 'draft')
    AND created_at >= now() - (p_days || ' days')::interval;
$$;

-- Grants
GRANT SELECT ON api.customers, api.payments, api.inspections, api.maintenance, api.invoices TO anon, authenticated;
GRANT EXECUTE ON FUNCTION api.create_customer TO anon, authenticated;
GRANT EXECUTE ON FUNCTION api.complete_checkin TO anon, authenticated;
GRANT EXECUTE ON FUNCTION api.complete_checkout TO anon, authenticated;
GRANT EXECUTE ON FUNCTION api.record_payment TO anon, authenticated;
GRANT EXECUTE ON FUNCTION api.get_revenue_report TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE ON customers, payments, vehicle_inspections, damage_reports,
  maintenance_records, invoices, tenant_users TO anon;

DO $$ BEGIN
  CREATE POLICY anon_read_customers ON customers FOR SELECT TO anon USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE POLICY anon_insert_customers ON customers FOR INSERT TO anon WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
