-- Enable uuid generator
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

------------------------------------------------------------
-- 1. Users
------------------------------------------------------------
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

------------------------------------------------------------
-- 2. Ingredients (Danh mục nguyên liệu chuẩn)
------------------------------------------------------------
CREATE TABLE ingredients (
    ingredient_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(150) NOT NULL,
    unit VARCHAR(50),
    category VARCHAR(100)
);

------------------------------------------------------------
-- 3. User Ingredients (Kho nguyên liệu ảo)
------------------------------------------------------------
CREATE TABLE user_ingredients (
    user_ing_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    ingredient_id UUID NOT NULL REFERENCES ingredients(ingredient_id) ON DELETE CASCADE,
    quantity DOUBLE PRECISION NOT NULL,
    unit VARCHAR(50),
    expiry_date DATE,
    added_at TIMESTAMP DEFAULT NOW()
);

------------------------------------------------------------
-- 4. Recipes (Công thức – mặc định sinh bởi AI/API)
------------------------------------------------------------
CREATE TABLE recipes (
    recipe_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    instructions TEXT,
    cooking_time INT,
    cuisine VARCHAR(100),
    source_type VARCHAR(50) DEFAULT 'AI',  -- AI / API / Manual
    created_at TIMESTAMP DEFAULT NOW()
);

------------------------------------------------------------
-- 5. Recipe Ingredients (Nhiều – nhiều)
------------------------------------------------------------
CREATE TABLE recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    ingredient_id UUID NOT NULL REFERENCES ingredients(ingredient_id) ON DELETE CASCADE,
    required_quantity DOUBLE PRECISION,
    required_unit VARCHAR(50)
);

------------------------------------------------------------
-- 6. Meal Plan (Lịch ăn uống)
------------------------------------------------------------
CREATE TABLE meal_plan (
    plan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    date DATE NOT NULL,
    meal_type VARCHAR(50) NOT NULL -- breakfast / lunch / dinner
);

------------------------------------------------------------
-- 7. Shopping List
------------------------------------------------------------
CREATE TABLE shopping_list (
    item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    ingredient_id UUID NOT NULL REFERENCES ingredients(ingredient_id) ON DELETE CASCADE,
    quantity_needed DOUBLE PRECISION,
    unit VARCHAR(50),
    status BOOLEAN DEFAULT FALSE
);

------------------------------------------------------------
-- 8. Notifications (Cảnh báo hết hạn)
------------------------------------------------------------
CREATE TABLE notifications (
    notify_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    user_ing_id UUID REFERENCES user_ingredients(user_ing_id) ON DELETE CASCADE,
    notify_type VARCHAR(100), -- expiry_warning / info / system
    message VARCHAR(500),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW().    
);         