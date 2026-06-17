-- Rentacar SaaS — Initial Migration
-- PostgreSQL 15+ | Multi-tenant with RLS

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

CREATE SCHEMA IF NOT EXISTS api;

-- TENANTS
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  tax_number VARCHAR(20),
  plan VARCHAR(50) DEFAULT 'starter',
  max_vehicles INT DEFAULT 10,
  settings JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE tenant_branding (
  tenant_id UUID PRIMARY KEY REFERENCES tenants(id) ON DELETE CASCADE,
  logo_url TEXT,
  favicon_url TEXT,
  primary_color VARCHAR(7) DEFAULT '#0B1F3A',
  accent_color VARCHAR(7) DEFAULT '#E8A317',
  hero_title VARCHAR(255) DEFAULT 'Yolculuğunuza Premium Başlayın',
  hero_subtitle TEXT,
  hero_image_url TEXT,
  about_html TEXT,
  contact_phone VARCHAR(20),
  whatsapp_number VARCHAR(20),
  social_links JSONB DEFAULT '{}',
  custom_domain VARCHAR(255),
  meta_title VARCHAR(255),
  meta_description TEXT
);

CREATE TABLE branches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  name VARCHAR(255) NOT NULL,
  address TEXT,
  city VARCHAR(100),
  latitude DECIMAL(10,7),
  longitude DECIMAL(10,7),
  phone VARCHAR(20),
  working_hours JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE vehicle_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  name VARCHAR(100) NOT NULL,
  code VARCHAR(20),
  daily_base_price DECIMAL(12,2) NOT NULL,
  deposit_amount DECIMAL(12,2) DEFAULT 0,
  min_driver_age INT DEFAULT 21,
  min_license_years INT DEFAULT 2,
  sort_order INT DEFAULT 0
);

CREATE TABLE vehicles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  branch_id UUID NOT NULL REFERENCES branches(id),
  category_id UUID NOT NULL REFERENCES vehicle_categories(id),
  plate_number VARCHAR(20) NOT NULL,
  vin VARCHAR(50),
  brand VARCHAR(100),
  model VARCHAR(100),
  year INT,
  color VARCHAR(50),
  fuel_type VARCHAR(20) DEFAULT 'petrol',
  transmission VARCHAR(20) DEFAULT 'automatic',
  current_km INT DEFAULT 0,
  status VARCHAR(30) DEFAULT 'available',
  features JSONB DEFAULT '[]',
  insurance_expiry DATE,
  inspection_expiry DATE,
  created_at TIMESTAMPTZ DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  UNIQUE(tenant_id, plate_number)
);

CREATE TYPE rental_status AS ENUM (
  'draft', 'pending', 'confirmed', 'active',
  'returned', 'closed', 'cancelled', 'no_show'
);

CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  type VARCHAR(20) DEFAULT 'individual',
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  company_name VARCHAR(255),
  identity_number VARCHAR(20),
  email VARCHAR(255),
  phone VARCHAR(20),
  birth_date DATE,
  is_blacklisted BOOLEAN DEFAULT false,
  loyalty_points INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE rentals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  rental_number VARCHAR(20) NOT NULL,
  customer_id UUID NOT NULL REFERENCES customers(id),
  vehicle_id UUID REFERENCES vehicles(id),
  category_id UUID NOT NULL REFERENCES vehicle_categories(id),
  pickup_branch_id UUID NOT NULL REFERENCES branches(id),
  return_branch_id UUID NOT NULL REFERENCES branches(id),
  pickup_at TIMESTAMPTZ NOT NULL,
  return_at TIMESTAMPTZ NOT NULL,
  rental_period TSTZRANGE GENERATED ALWAYS AS (tstzrange(pickup_at, return_at, '[)')) STORED,
  status rental_status DEFAULT 'draft',
  channel VARCHAR(30) DEFAULT 'web',
  base_price DECIMAL(12,2),
  total_price DECIMAL(12,2),
  deposit_amount DECIMAL(12,2),
  currency VARCHAR(3) DEFAULT 'TRY',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(tenant_id, rental_number),
  CONSTRAINT no_overlapping_rentals EXCLUDE USING gist (
    tenant_id WITH =,
    vehicle_id WITH =,
    rental_period WITH &&
  ) WHERE (vehicle_id IS NOT NULL AND status NOT IN ('cancelled', 'draft'))
);

CREATE INDEX idx_vehicles_tenant_status ON vehicles(tenant_id, status);
CREATE INDEX idx_rentals_tenant_dates ON rentals(tenant_id, pickup_at, return_at);
CREATE INDEX idx_branches_tenant ON branches(tenant_id);

-- RLS
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles FORCE ROW LEVEL SECURITY;
ALTER TABLE rentals ENABLE ROW LEVEL SECURITY;
ALTER TABLE rentals FORCE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers FORCE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_vehicles ON vehicles
  USING (tenant_id = (current_setting('request.jwt.claims', true)::json->>'tenant_id')::uuid);

CREATE POLICY tenant_isolation_rentals ON rentals
  USING (tenant_id = (current_setting('request.jwt.claims', true)::json->>'tenant_id')::uuid);

CREATE POLICY tenant_isolation_customers ON customers
  USING (tenant_id = (current_setting('request.jwt.claims', true)::json->>'tenant_id')::uuid);

-- Demo seed
INSERT INTO tenants (id, name, slug) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Premium Rent', 'premium-rent');

INSERT INTO tenant_branding (tenant_id, hero_subtitle, contact_phone) VALUES
  ('00000000-0000-0000-0000-000000000001',
   'Geniş filomuzdan size en uygun aracı seçin, dakikalar içinde kirala.',
   '+90 212 555 0100');
