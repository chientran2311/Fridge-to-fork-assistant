-- USERS
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(320) UNIQUE NOT NULL,
  password_hash TEXT, -- nullable if using SSO
  display_name VARCHAR(100),
  phone VARCHAR(20),
  avatar_url TEXT,
  language VARCHAR(10) DEFAULT 'vi',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  is_admin BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true
);

-- FRIENDSHIPS (mutual or request model)
CREATE TABLE friendships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  addressee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending, accepted, rejected
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE (requester_id, addressee_id)
);

-- INGREDIENTS (master list / catalog)
CREATE TABLE ingredients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  canonical_name TEXT, -- normalized
  unit VARCHAR(30), -- default unit suggestion
  category VARCHAR(50),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_ingredients_name ON ingredients USING gin (to_tsvector('english', name));

-- PANTRY ITEMS (user-specific current stock)
CREATE TABLE pantry_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  ingredient_id UUID REFERENCES ingredients(id),
  name TEXT NOT NULL, -- free-text fallback if ingredient_id null
  quantity NUMERIC DEFAULT 1,
  unit VARCHAR(30),
  purchase_date DATE,
  expiry_date DATE,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_pantry_user_expiry ON pantry_items (user_id, expiry_date);
CREATE INDEX idx_pantry_user_ing ON pantry_items (user_id, ingredient_id);

-- RECIPES (can be from external API or created)
CREATE TABLE recipes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  instructions TEXT, -- could be JSON or markdown
  cook_time_minutes INT,
  servings INT,
  cuisine VARCHAR(50),
  meal_type VARCHAR(50), -- breakfast, lunch, dinner
  source VARCHAR(100), -- 'spoonacular', 'user', 'internal_ai'
  source_id TEXT, -- id in external API
  image_url TEXT,
  created_by UUID REFERENCES users(id), -- null if system
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_recipes_title ON recipes USING gin (to_tsvector('english', title));

-- RECIPE_INGREDIENTS (many-to-many)
CREATE TABLE recipe_ingredients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  ingredient_id UUID REFERENCES ingredients(id),
  name TEXT NOT NULL, -- fallback text
  quantity NUMERIC,
  unit VARCHAR(30),
  position INT DEFAULT 0
);

CREATE INDEX idx_recipe_ing_recipe ON recipe_ingredients (recipe_id);
CREATE INDEX idx_recipe_ing_ingredient ON recipe_ingredients (ingredient_id);

-- SHOPPING LISTS
CREATE TABLE shopping_lists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT,
  is_done BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE shopping_list_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
  ingredient_id UUID REFERENCES ingredients(id),
  name TEXT NOT NULL,
  quantity NUMERIC DEFAULT 1,
  unit VARCHAR(30),
  is_bought BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- MEAL PLANS (user calendar)
CREATE TABLE meal_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  recipe_id UUID REFERENCES recipes(id),
  plan_date DATE NOT NULL,
  meal_slot VARCHAR(20), -- breakfast/lunch/dinner/snack
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_mealplans_user_date ON meal_plans (user_id, plan_date);

-- NOTIFICATIONS (for push / in-app)
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL, -- expiry_reminder, promo, etc
  payload JSONB, -- e.g. {"pantry_item_id": "..."}
  is_sent BOOLEAN DEFAULT false,
  sent_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- API KEYS / CONFIG (managed by admin)
CREATE TABLE api_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL, -- 'spoonacular', 'openai'
  config JSONB NOT NULL, -- {"api_key":"xxx", "enabled":true}
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ANALYTICS / STATS (simple)
CREATE TABLE analytics_events (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID,
  event_type VARCHAR(100),
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- SIMPLE AUDIT LOG
CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  actor_id UUID,
  action VARCHAR(200),
  object_type VARCHAR(100),
  object_id TEXT,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
