# 📋 Shopping List - How It Works

## 🎯 Overview
Shopping List hoạt động bằng cách **tính toán động** những nguyên liệu cần mua dựa trên:
- **Meal Plans** (Những bữa ăn đã lên kế hoạch)
- **Recipes** (Công thức nấu với danh sách nguyên liệu)
- **Inventory** (Kho nguyên liệu hiện có)

---

## 🔄 Step-by-Step Flow

### **Step 1: Load Meal Plans** 📅
```
Fetch ALL meal_plans từ: households/house_01/meal_plans

Ví dụ:
- 29/12/2025: Breakfast (Recipe: recipe_02 - Trứng Cà Chua)
- 29/12/2025: Dinner (Recipe: recipe_01 - Bò Kho Tiêu)
- 31/12/2025: Breakfast (Recipe: recipe_03 - Canh Cà Chua Trứng)
- 31/12/2025: Lunch (Recipe: recipe_05 - Canh Dưa Trứng)
- 31/12/2025: Dinner (Recipe: recipe_04 - Bò Kho Cà Rốt)
```

### **Step 2: Load Inventory** 📦
```
Fetch ALL inventory từ: households/house_01/inventory

Tạo inventory map:
{
  'ing_0001': 800,    // Beef: 800g
  'ing_0002': 20,     // Eggs: 20 pcs
  'ing_0003': 8,      // Onion: 8 pcs
  'ing_0004': 6,      // Tomato: 6 pcs
  ...
}
```

### **Step 3: For Each Meal Plan - Fetch Recipe** 🍳
```
Ví dụ: Meal plan on 29/12 - Recipe recipe_01 (Bò Kho Tiêu)

Fetch recipe từ: households/house_01/household_recipes/recipe_01

Recipe data:
{
  'title': 'Bò Kho Tiêu',
  'ingredients': [
    {'ingredient_id': 'ing_0001', 'amount': 300, 'unit': 'g'},    // Beef
    {'ingredient_id': 'ing_0003', 'amount': 2, 'unit': 'pcs'},    // Onion
    {'ingredient_id': 'ing_0007', 'amount': 5, 'unit': 'g'},      // Black pepper
    {'ingredient_id': 'ing_0008', 'amount': 30, 'unit': 'ml'},    // Oil
  ]
}
```

### **Step 4: Calculate Needed Items** 🧮
```
Cho mỗi ingredient trong recipe:

Cần = Required Qty - Available Qty (từ inventory)

Ví dụ (Bò Kho Tiêu):
1. Beef:
   - Required: 300g
   - Available: 800g
   - Needed: 300 - 800 = -500 (KHÔNG CẦN - đủ rồi) ❌

2. Onion:
   - Required: 2 pcs
   - Available: 8 pcs
   - Needed: 2 - 8 = -6 (KHÔNG CẦN) ❌

3. Black pepper:
   - Required: 5g
   - Available: 20g
   - Needed: 5 - 20 = -15 (KHÔNG CẦN) ❌

4. Oil:
   - Required: 30ml
   - Available: 750ml
   - Needed: 30 - 750 = -720 (KHÔNG CẦN) ❌

➡️ Kết quả: Bò Kho Tiêu - KHÔNG CẦN MUA GÌ (tất cả đủ trong kho)
```

### **Step 5: Group by Date** 📅
```
Lặp lại Step 3-4 cho TẤT CẢ meal plans

Kết quả cuối cùng, nhóm theo ngày:

29/12/2025:
  [Trứng Cà Chua items if needed]
  [Bò Kho Tiêu items if needed]

31/12/2025:
  [Canh Cà Chua Trứng items if needed]
  [Canh Dưa Trứng items if needed]
  [Bò Kho Cà Rốt items if needed]
```

---

## 📊 Example Scenario

### **Situation:**
Inventory chỉ có:
```
- Beef: 50g (ít)
- Eggs: 2 pcs (ít)
- Tomato: 1 pc (ít)
- Everything else: Đủ
```

### **Shopping List Result:**

```
📅 29/12/2025
├─ Beef (meat)
│  ├─ Trứng Cà Chua: cần (300g - 50g) = 250g
│  └─ Bò Kho Tiêu: cần (300g - 50g) = 250g
│  💡 Tổng: 500g BEEF CẦN MUA
│
├─ Eggs (dairy)
│  ├─ Trứng Cà Chua: cần (3 - 2) = 1 pc
│  └─ Bò Kho Tiêu: không dùng
│  💡 Tổng: 1 EGG CẦN MUA
│
└─ Tomato (vegetable)
   ├─ Trứng Cà Chua: cần (2 - 1) = 1 pc
   └─ Bò Kho Tiêu: không dùng
   💡 Tổng: 1 TOMATO CẦN MUA

📅 31/12/2025
├─ Eggs: cần (2 + 3 + 2) - 2 = 5 pcs
├─ Tomato: cần (3 + 0 + 0) - 1 = 2 pcs
├─ Carrot: cần (3 - 0) = 3 pcs
└─ ...
```

---

## 🎮 User Interactions

### **1. Check Item** ✅
```
User tap checkbox → Item marked as 'is_checked = true'
📌 Local state only (NOT saved to Firebase)
```

### **2. Edit Quantity** ✏️
```
User tap +/- button → Change quantity
📌 Local state only (NOT saved to Firebase)

Example: Beef 500g → User click + → 600g
```

### **3. Delete Item** 🗑️
```
User swipe/tap delete → Item removed from list
📌 Local state only (NOT saved to Firebase)

Example: Remove Tomato from shopping list
```

### **4. Refresh** 🔄
```
Widget reload → _loadShoppingListByDate() runs again
✅ Recalculates from Firebase (all local changes lost)
✅ Fresh data from meal_plans + inventory
```

---

## 💾 Local State vs Firebase

| Action | Local | Firebase |
|--------|-------|----------|
| ✅ Check item | Yes | No |
| ✏️ Edit quantity | Yes | No |
| 🗑️ Delete item | Yes | No |
| 📚 Core data (ingredients, recipes, meal_plans) | No | Yes |
| 🔄 Refresh/Reload | Lost | Restored |

---

## ⚠️ Important Notes

### **1. Shopping List is Auto-Generated**
- Không lưu ở collection `shopping_list` (được tạo từ seeder)
- Được tính toán từ meal_plans + recipes + inventory
- Mỗi lần load = tính lại từ đầu

### **2. Local Edits are Temporary**
- Người dùng có thể chỉnh sửa (check, edit qty, delete)
- Nhưng nếu widget reload hoặc app restart → mất hết
- Để lưu, cần implement persistence (SharedPreferences hoặc Firebase)

### **3. Duplicate Prevention**
```dart
// Nếu 2 meal plans cùng cần Beef, chỉ show 1 dòng
if (!itemsByDate[dateKey]!.any((it) => it['ingredient_id'] == ingredientId)) {
  itemsByDate[dateKey]!.add(item);
}
```

---

## 🔧 Future Improvements

```
1. 💾 Persist local changes (SharedPreferences)
2. 🔗 Sync checked items to Firebase
3. 📊 Show item status (In stock, Partially, Need to buy)
4. 🏪 Link to shopping app integration
5. 📱 Mark items as "Bought" with Firebase sync
```

---

## 📝 Code Location
- **Main**: `lib/screens/meal&plan/tabs/shopping_list/shopping_list_tab.dart`
- **UI Components**: `lib/widgets/plans/tabs/shopping_list_tab/`
  - `shopping_item.dart` - Individual item widget
  - `shopping_filter.dart` - Category filter
  - `section_header.dart` - Date header

---

## 🎯 Summary
```
Meal Plans + Recipes + Inventory
        ↓
   Calculate Needed Items
        ↓
   Group by Date
        ↓
   Display Shopping List
        ↓
   User Edits Locally (NOT saved)
        ↓
   Refresh → Recalculate from Firebase
```
