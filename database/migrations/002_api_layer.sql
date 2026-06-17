-- Rentacar SaaS — API Layer, Roles, Seed Data, RPC Functions

-- Roles
DO $$ BEGIN
  CREATE ROLE anon NOLOGIN;
  CREATE ROLE authenticated NOLOGIN;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT USAGE ON SCHEMA api TO anon, authenticated;

-- Demo tenant seed (branches, categories, vehicles, customer)
INSERT INTO branches (id, tenant_id, name, city, phone) VALUES
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Merkez Şube', 'İstanbul', '+90 212 555 0100'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Havalimanı', 'İstanbul', '+90 212 555 0101')
ON CONFLICT DO NOTHING;

INSERT INTO vehicle_categories (id, tenant_id, name, code, daily_base_price, deposit_amount, sort_order) VALUES
  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Ekonomi', 'ECON', 650, 2000, 1),
  ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Sedan', 'SEDAN', 1850, 5000, 2),
  ('20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'SUV', 'SUV', 2400, 7000, 3),
  ('20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'Lüks', 'LUX', 3200, 10000, 4)
ON CONFLICT DO NOTHING;

INSERT INTO vehicles (id, tenant_id, branch_id, category_id, plate_number, brand, model, year, fuel_type, transmission, current_km, status, features) VALUES
  ('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', '34 ABC 123', 'BMW', '320i', 2024, 'petrol', 'automatic', 12500, 'available', '["GPS","Bluetooth","Deri Koltuk"]'),
  ('30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', '34 DEF 456', 'Mercedes', 'GLC 200', 2023, 'petrol', 'automatic', 28000, 'available', '["AWD","Panoramik Tavan"]'),
  ('30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '34 GHI 789', 'Renault', 'Clio', 2024, 'petrol', 'manual', 8500, 'rented', '["Klima","Bluetooth"]'),
  ('30000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', '34 JKL 012', 'Audi', 'A6', 2024, 'petrol', 'automatic', 5200, 'available', '["Matrix LED","Massage Koltuk"]'),
  ('30000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '34 MNO 345', 'Fiat', 'Egea', 2023, 'diesel', 'manual', 41000, 'available', '["Klima"]'),
  ('30000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', '34 PQR 678', 'Volvo', 'XC60', 2024, 'hybrid', 'automatic', 9800, 'maintenance', '["AWD","Pilot Assist"]')
ON CONFLICT DO NOTHING;

INSERT INTO customers (id, tenant_id, first_name, last_name, email, phone, identity_number) VALUES
  ('40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Ahmet', 'Yılmaz', 'ahmet@example.com', '05321234567', '12345678901')
ON CONFLICT DO NOTHING;

-- Public API views
CREATE OR REPLACE VIEW api.vehicles AS
SELECT
  v.id,
  v.tenant_id,
  v.branch_id,
  b.name AS branch_name,
  v.category_id,
  c.name AS category_name,
  c.code AS category_code,
  c.daily_base_price,
  c.deposit_amount,
  v.plate_number,
  v.brand,
  v.model,
  v.year,
  v.color,
  v.fuel_type,
  v.transmission,
  v.current_km,
  v.status,
  v.features,
  v.created_at
FROM vehicles v
JOIN branches b ON b.id = v.branch_id
JOIN vehicle_categories c ON c.id = v.category_id
WHERE v.deleted_at IS NULL;

CREATE OR REPLACE VIEW api.branches AS
SELECT id, tenant_id, name, address, city, phone, working_hours, is_active
FROM branches
WHERE is_active = true;

CREATE OR REPLACE VIEW api.rentals AS
SELECT
  r.id,
  r.tenant_id,
  r.rental_number,
  r.customer_id,
  r.vehicle_id,
  r.category_id,
  r.pickup_branch_id,
  r.return_branch_id,
  r.pickup_at,
  r.return_at,
  r.status::text AS status,
  r.channel,
  r.base_price,
  r.total_price,
  r.deposit_amount,
  r.currency,
  r.created_at,
  v.plate_number,
  v.brand,
  v.model,
  c.first_name || ' ' || c.last_name AS customer_name
FROM rentals r
LEFT JOIN vehicles v ON v.id = r.vehicle_id
LEFT JOIN customers c ON c.id = r.customer_id;

-- Rental number sequence per tenant (simplified)
CREATE OR REPLACE FUNCTION api.next_rental_number(p_tenant_id uuid)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  v_count int;
BEGIN
  SELECT count(*) + 1 INTO v_count FROM rentals WHERE tenant_id = p_tenant_id;
  RETURN 'RNT-' || to_char(now(), 'YYYY') || '-' || lpad(v_count::text, 5, '0');
END;
$$;

-- Price calculator
CREATE OR REPLACE FUNCTION api.calculate_rental_price(
  p_tenant_id uuid,
  p_category_id uuid,
  p_pickup_at timestamptz,
  p_return_at timestamptz
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
DECLARE
  v_daily_price decimal(12,2);
  v_deposit decimal(12,2);
  v_days int;
  v_base decimal(12,2);
  v_tax decimal(12,2);
  v_total decimal(12,2);
BEGIN
  IF p_return_at <= p_pickup_at THEN
    RAISE EXCEPTION 'return date must be after pickup date';
  END IF;

  SELECT daily_base_price, deposit_amount
  INTO v_daily_price, v_deposit
  FROM vehicle_categories
  WHERE id = p_category_id AND tenant_id = p_tenant_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'category not found';
  END IF;

  v_days := GREATEST(1, ceil(extract(epoch FROM (p_return_at - p_pickup_at)) / 86400)::int);
  v_base := v_daily_price * v_days;
  v_tax := round(v_base * 0.20, 2);
  v_total := v_base + v_tax;

  RETURN jsonb_build_object(
    'days', v_days,
    'daily_price', v_daily_price,
    'base_price', v_base,
    'tax_amount', v_tax,
    'total_price', v_total,
    'deposit_amount', v_deposit,
    'currency', 'TRY'
  );
END;
$$;

-- Check vehicle availability
CREATE OR REPLACE FUNCTION api.check_vehicle_availability(
  p_tenant_id uuid,
  p_vehicle_id uuid,
  p_pickup_at timestamptz,
  p_return_at timestamptz
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
  SELECT NOT EXISTS (
    SELECT 1 FROM rentals r
    WHERE r.tenant_id = p_tenant_id
      AND r.vehicle_id = p_vehicle_id
      AND r.status NOT IN ('cancelled', 'draft')
      AND r.rental_period && tstzrange(p_pickup_at, p_return_at, '[)')
  )
  AND EXISTS (
    SELECT 1 FROM vehicles v
    WHERE v.id = p_vehicle_id
      AND v.tenant_id = p_tenant_id
      AND v.status = 'available'
      AND v.deleted_at IS NULL
  );
$$;

-- Create rental (atomic)
CREATE OR REPLACE FUNCTION api.create_rental(
  p_tenant_id uuid,
  p_customer_id uuid,
  p_vehicle_id uuid,
  p_category_id uuid,
  p_pickup_branch_id uuid,
  p_return_branch_id uuid,
  p_pickup_at timestamptz,
  p_return_at timestamptz,
  p_channel text DEFAULT 'web'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
DECLARE
  v_price jsonb;
  v_rental_id uuid;
  v_rental_number text;
  v_available boolean;
BEGIN
  SELECT api.check_vehicle_availability(p_tenant_id, p_vehicle_id, p_pickup_at, p_return_at)
  INTO v_available;

  IF NOT v_available THEN
    RAISE EXCEPTION 'vehicle not available for selected dates' USING ERRCODE = 'P0001';
  END IF;

  v_price := api.calculate_rental_price(p_tenant_id, p_category_id, p_pickup_at, p_return_at);
  v_rental_number := api.next_rental_number(p_tenant_id);

  INSERT INTO rentals (
    tenant_id, rental_number, customer_id, vehicle_id, category_id,
    pickup_branch_id, return_branch_id, pickup_at, return_at,
    status, channel, base_price, total_price, deposit_amount, currency
  ) VALUES (
    p_tenant_id, v_rental_number, p_customer_id, p_vehicle_id, p_category_id,
    p_pickup_branch_id, p_return_branch_id, p_pickup_at, p_return_at,
    'confirmed', p_channel,
    (v_price->>'base_price')::decimal,
    (v_price->>'total_price')::decimal,
    (v_price->>'deposit_amount')::decimal,
    'TRY'
  )
  RETURNING id INTO v_rental_id;

  UPDATE vehicles SET status = 'reserved' WHERE id = p_vehicle_id;

  RETURN jsonb_build_object(
    'id', v_rental_id,
    'rental_number', v_rental_number,
    'price', v_price
  );
END;
$$;

-- Dashboard stats
CREATE OR REPLACE FUNCTION api.get_dashboard_stats(p_tenant_id uuid)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
  SELECT jsonb_build_object(
    'active_rentals', (SELECT count(*) FROM rentals WHERE tenant_id = p_tenant_id AND status = 'active'),
    'today_pickups', (SELECT count(*) FROM rentals WHERE tenant_id = p_tenant_id AND pickup_at::date = current_date AND status IN ('confirmed', 'active')),
    'today_returns', (SELECT count(*) FROM rentals WHERE tenant_id = p_tenant_id AND return_at::date = current_date AND status IN ('active', 'returned')),
    'total_vehicles', (SELECT count(*) FROM vehicles WHERE tenant_id = p_tenant_id AND deleted_at IS NULL),
    'available_vehicles', (SELECT count(*) FROM vehicles WHERE tenant_id = p_tenant_id AND status = 'available' AND deleted_at IS NULL),
    'utilization_rate', round(
      (SELECT count(*)::decimal FROM vehicles WHERE tenant_id = p_tenant_id AND status IN ('rented', 'reserved') AND deleted_at IS NULL)
      / NULLIF((SELECT count(*) FROM vehicles WHERE tenant_id = p_tenant_id AND deleted_at IS NULL), 0) * 100, 1
    ),
    'monthly_revenue', (SELECT coalesce(sum(total_price), 0) FROM rentals WHERE tenant_id = p_tenant_id AND status NOT IN ('cancelled', 'draft') AND created_at >= date_trunc('month', now()))
  );
$$;

-- Grants
GRANT SELECT ON api.vehicles TO anon, authenticated;
GRANT SELECT ON api.branches TO anon, authenticated;
GRANT SELECT ON api.rentals TO authenticated;

GRANT EXECUTE ON FUNCTION api.calculate_rental_price TO anon, authenticated;
GRANT EXECUTE ON FUNCTION api.check_vehicle_availability TO anon, authenticated;
GRANT EXECUTE ON FUNCTION api.create_rental TO anon, authenticated;
GRANT EXECUTE ON FUNCTION api.get_dashboard_stats TO authenticated;

-- Anon read policies for demo (tenant filter in app layer via query param)
CREATE POLICY anon_read_vehicles ON vehicles FOR SELECT TO anon USING (true);
CREATE POLICY anon_read_branches ON branches FOR SELECT TO anon USING (true);
CREATE POLICY anon_read_categories ON vehicle_categories FOR SELECT TO anon USING (true);

GRANT SELECT ON vehicles, branches, vehicle_categories, customers, rentals TO anon;
GRANT INSERT ON customers, rentals TO anon;
GRANT UPDATE ON vehicles TO anon;

ALTER DEFAULT PRIVILEGES IN SCHEMA api GRANT EXECUTE ON FUNCTIONS TO anon, authenticated;
