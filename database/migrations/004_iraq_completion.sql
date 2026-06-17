-- Irak tamamlama: IQD, auth login, iptal, branding, genişletilmiş ödeme, bakım, fatura

ALTER TABLE payments ALTER COLUMN currency SET DEFAULT 'IQD';

UPDATE tenant_branding SET
  hero_title = 'ابدأ رحلتك بتميز',
  hero_subtitle = 'اختر السيارة المناسبة من أسطولنا الواسع واستأجر خلال دقائق.',
  contact_phone = '+964 770 000 0000',
  whatsapp_number = '9647700000000'
WHERE tenant_id = '00000000-0000-0000-0000-000000000001';

CREATE OR REPLACE VIEW api.tenant_branding AS
SELECT
  tb.tenant_id, tb.logo_url, tb.primary_color, tb.accent_color,
  tb.hero_title, tb.hero_subtitle, tb.hero_image_url,
  tb.contact_phone, tb.whatsapp_number, tb.custom_domain,
  t.name AS tenant_name, t.slug AS tenant_slug
FROM tenant_branding tb
JOIN tenants t ON t.id = tb.tenant_id;

-- Login (bcrypt)
CREATE OR REPLACE FUNCTION api.login_tenant_user(
  p_tenant_id uuid,
  p_email text,
  p_password text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
DECLARE v_user tenant_users%ROWTYPE;
BEGIN
  SELECT * INTO v_user FROM tenant_users
  WHERE tenant_id = p_tenant_id AND lower(email) = lower(p_email) AND is_active = true;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'invalid credentials';
  END IF;

  IF v_user.password_hash = crypt(p_password, v_user.password_hash) THEN
    RETURN jsonb_build_object(
      'id', v_user.id,
      'tenant_id', v_user.tenant_id,
      'email', v_user.email,
      'full_name', v_user.full_name,
      'role', v_user.role
    );
  END IF;

  RAISE EXCEPTION 'invalid credentials';
END;
$$;

-- Rezervasyon iptali
CREATE OR REPLACE FUNCTION api.cancel_rental(
  p_tenant_id uuid,
  p_rental_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
DECLARE v_vehicle_id uuid;
BEGIN
  SELECT vehicle_id INTO v_vehicle_id FROM rentals
  WHERE id = p_rental_id AND tenant_id = p_tenant_id AND status IN ('draft', 'confirmed');

  IF NOT FOUND THEN
    RAISE EXCEPTION 'rental cannot be cancelled';
  END IF;

  UPDATE rentals SET status = 'cancelled', updated_at = now()
  WHERE id = p_rental_id;

  IF v_vehicle_id IS NOT NULL THEN
    UPDATE vehicles SET status = 'available' WHERE id = v_vehicle_id AND status = 'reserved';
  END IF;

  RETURN jsonb_build_object('id', p_rental_id, 'status', 'cancelled');
END;
$$;

-- Vitrin branding güncelle
CREATE OR REPLACE FUNCTION api.update_tenant_branding(
  p_tenant_id uuid,
  p_hero_title text DEFAULT NULL,
  p_hero_subtitle text DEFAULT NULL,
  p_contact_phone text DEFAULT NULL,
  p_whatsapp_number text DEFAULT NULL,
  p_primary_color text DEFAULT NULL,
  p_accent_color text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
BEGIN
  UPDATE tenant_branding SET
    hero_title = coalesce(p_hero_title, hero_title),
    hero_subtitle = coalesce(p_hero_subtitle, hero_subtitle),
    contact_phone = coalesce(p_contact_phone, contact_phone),
    whatsapp_number = coalesce(p_whatsapp_number, whatsapp_number),
    primary_color = coalesce(p_primary_color, primary_color),
    accent_color = coalesce(p_accent_color, accent_color)
  WHERE tenant_id = p_tenant_id;

  RETURN jsonb_build_object('ok', true);
END;
$$;

-- Genişletilmiş ödeme kaydı
CREATE OR REPLACE FUNCTION api.record_payment(
  p_tenant_id uuid,
  p_rental_id uuid,
  p_customer_id uuid,
  p_type text,
  p_amount decimal,
  p_method text DEFAULT 'card',
  p_currency text DEFAULT 'IQD',
  p_provider text DEFAULT NULL,
  p_provider_transaction_id text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
DECLARE v_id uuid;
BEGIN
  INSERT INTO payments (
    tenant_id, rental_id, customer_id, type, amount, currency, method,
    status, provider, provider_transaction_id, paid_at
  )
  VALUES (
    p_tenant_id, p_rental_id, p_customer_id, p_type, p_amount, p_currency, p_method,
    'completed', p_provider, p_provider_transaction_id, now()
  )
  RETURNING id INTO v_id;

  RETURN jsonb_build_object('id', v_id, 'status', 'completed');
END;
$$;

-- Bakım kaydı
CREATE OR REPLACE FUNCTION api.create_maintenance(
  p_tenant_id uuid,
  p_vehicle_id uuid,
  p_type text DEFAULT 'periodic',
  p_description text DEFAULT NULL,
  p_km_at_service int DEFAULT NULL,
  p_cost decimal DEFAULT 0,
  p_scheduled_at date DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
DECLARE v_id uuid;
BEGIN
  INSERT INTO maintenance_records (
    tenant_id, vehicle_id, type, description, km_at_service, cost, scheduled_at, status
  )
  VALUES (
    p_tenant_id, p_vehicle_id, p_type, p_description, p_km_at_service, p_cost,
    coalesce(p_scheduled_at, current_date), 'scheduled'
  )
  RETURNING id INTO v_id;

  RETURN jsonb_build_object('id', v_id);
END;
$$;

-- Fatura oluştur
CREATE OR REPLACE FUNCTION api.create_invoice(
  p_tenant_id uuid,
  p_rental_id uuid,
  p_customer_id uuid,
  p_subtotal decimal,
  p_tax_amount decimal
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, api, pg_temp
AS $$
DECLARE
  v_id uuid;
  v_num text;
  v_total decimal;
BEGIN
  v_total := p_subtotal + p_tax_amount;
  v_num := 'INV-' || to_char(now(), 'YYYY') || '-' || lpad(
    (SELECT count(*) + 1 FROM invoices WHERE tenant_id = p_tenant_id)::text, 5, '0');

  INSERT INTO invoices (
    tenant_id, rental_id, customer_id, invoice_number,
    subtotal, tax_amount, total_amount, status, issued_at
  )
  VALUES (
    p_tenant_id, p_rental_id, p_customer_id, v_num,
    p_subtotal, p_tax_amount, v_total, 'issued', now()
  )
  RETURNING id INTO v_id;

  RETURN jsonb_build_object('id', v_id, 'invoice_number', v_num, 'total', v_total);
END;
$$;

-- Hasar fotoğrafları ile check-out
CREATE OR REPLACE FUNCTION api.complete_checkout(
  p_tenant_id uuid,
  p_rental_id uuid,
  p_km_reading int,
  p_fuel_level int,
  p_damage_cost decimal DEFAULT 0,
  p_notes text DEFAULT NULL,
  p_photo_urls jsonb DEFAULT '[]'::jsonb
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

  IF jsonb_array_length(p_photo_urls) > 0 THEN
    INSERT INTO damage_reports (tenant_id, inspection_id, vehicle_id, part, damage_type, photo_urls)
    VALUES (p_tenant_id, v_inspection_id, v_vehicle_id, 'general', 'photo', p_photo_urls);
  END IF;

  UPDATE rentals SET status = 'returned', updated_at = now() WHERE id = p_rental_id;
  UPDATE vehicles SET status = 'available', current_km = p_km_reading WHERE id = v_vehicle_id;

  IF p_damage_cost > 0 THEN
    INSERT INTO payments (tenant_id, rental_id, customer_id, type, amount, currency, method, status, notes)
    VALUES (p_tenant_id, p_rental_id, v_customer_id, 'damage', p_damage_cost, 'IQD', 'card', 'pending',
            'Hasar kesintisi — check-out', NULL);
  END IF;

  RETURN jsonb_build_object('inspection_id', v_inspection_id, 'status', 'returned');
END;
$$;

GRANT SELECT ON api.tenant_branding TO anon, authenticated;
GRANT EXECUTE ON FUNCTION api.login_tenant_user TO anon, authenticated;
GRANT EXECUTE ON FUNCTION api.cancel_rental TO anon, authenticated;
GRANT EXECUTE ON FUNCTION api.update_tenant_branding TO anon, authenticated;
GRANT EXECUTE ON FUNCTION api.create_maintenance TO anon, authenticated;
GRANT EXECUTE ON FUNCTION api.create_invoice TO anon, authenticated;
