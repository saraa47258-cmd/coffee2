# إعداد قواعد Firestore للأدمن

## المشكلة
الأدمن يحتاج إلى قراءة جميع الطلبات من collection `orders`، لكن القواعد الحالية تمنع ذلك.

## الحل
تم تحديث الكود لحفظ الطلبات في مكانين:
1. `users/{uid}/orders/{orderId}` - للمستخدمين العاديين
2. `orders/{orderId}` - collection عام للأدمن

## خطوات التحديث

### 1. تحديث Firestore Security Rules

اذهب إلى [Firebase Console](https://console.firebase.google.com/) → مشروعك → Firestore Database → Rules

انسخ والصق القواعد التالية:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null && 
             exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Helper function to check if user owns the resource
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }
    
    // Users collection - users can read their own data, admins can read all
    match /users/{userId} {
      allow read: if isOwner(userId) || isAdmin();
      allow write: if isOwner(userId) || isAdmin();
      
      // User's orders - users can read/write their own orders
      match /orders/{orderId} {
        allow read, write: if isOwner(userId);
      }
      
      // User's cart items - users can read/write their own cart
      match /cartItems/{itemId} {
        allow read, write: if isOwner(userId);
      }
      
      // User's favorites - users can read/write their own favorites
      match /favorites/{favoriteId} {
        allow read, write: if isOwner(userId);
      }
    }
    
    // Global orders collection - only admins can read, users can write their own orders
    match /orders/{orderId} {
      allow read: if isAdmin();
      allow create: if request.auth != null && 
                      request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAdmin();
    }
  }
}
```

### 2. اضغط "Publish" لحفظ القواعد

### 3. إنشاء حساب أدمن (إذا لم يكن موجوداً)

1. سجّل مستخدم عادي من التطبيق
2. اذهب إلى Firestore Database
3. افتح collection `users`
4. ابحث عن document بمعرف المستخدم
5. أضف أو عدّل field `role` إلى `"admin"`

### 4. اختبار

- سجّل دخول بحساب أدمن
- يجب أن تتمكن من رؤية جميع الطلبات في لوحة التحكم

## ملاحظات

- القواعد الجديدة تسمح للمستخدمين بإنشاء طلبات في `orders` collection
- فقط الأدمن يمكنه قراءة جميع الطلبات
- المستخدمون العاديون يقرأون طلباتهم من `users/{uid}/orders`

