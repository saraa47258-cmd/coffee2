# إعداد التطبيق للويب

## متطلبات التشغيل

1. **Firebase Web Configuration**:
   - يجب الحصول على Web App ID من Firebase Console
   - تحديث `lib/firebase_options.dart` بإضافة Web App ID الصحيح

2. **تشغيل التطبيق على الويب**:
   ```bash
   flutter run -d chrome
   ```

3. **بناء التطبيق للإنتاج**:
   ```bash
   flutter build web
   ```

## ملاحظات مهمة

- التطبيق جاهز للتشغيل على الويب
- Firebase يحتاج إلى Web App ID من Firebase Console
- image_picker قد يحتاج إلى إعدادات إضافية على الويب
- التطبيق متجاوب ويعمل على جميع أحجام الشاشات

## الحصول على Web App ID من Firebase

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. اختر مشروعك
3. اذهب إلى Project Settings
4. في قسم "Your apps"، اختر Web app أو أنشئ واحداً جديداً
5. انسخ App ID وأضفه في `lib/firebase_options.dart`

