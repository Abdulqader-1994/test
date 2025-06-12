import 'package:graphql_flutter/graphql_flutter.dart';
import 'auth.dart';

class ApiResponse {
  static Map errors = {
    'UNKNOW_ERROR': 'خطأ غير معروف، الرجاء المحاولة لاحقاً',
    'INVALID_TOKEN': 'حدث خطأ أثناء عملية تسجيل الدخول، الرجاء المحاولة مرة أخرى',
    'UN_AUTHED': 'الرجاء تسجيل الدخول أولاً',
    'USERNAME_CHARS_MIN': 'اسم المستخدم يجب أن لا يقل عن 5 أحرف',
    'DATA_EXIST': 'الإيميل أو اسم المستخدم موجود مسبقاً، الرجاء تعديل المعلومات',
    'TOO_MANY_EMAIL': 'الرجاء الانتظار مدة أقصاها 3 دقائق قبل إرسال إيميل آخر',
    'CODE_INVALID': 'الكود غير صحيح، الرجاء إدخاله مرة أخرى',
    'WRONG_DATA': 'الإيميل أو كلمة السر غير صحيح',
    'UNVERIFIED_EMAIL': 'الإيميل غير مفعل، الرجاء توثيق إيميلك الإلكتروني',
    'TASK_TIME_EXCEEDED': 'لقد ألغيت المهمة بسبب تجاوز وقت الحجز',
    'DO_YOUR_TASK': 'يجب عليك أن تنهي مهمتك أولاً قبل تنفيذ مهمة أخرى',
    'ZERO_TRUST': 'إن نقاط مصداقيتك هي صفر. نرجو انتظار انتهاء عملية التحقق من المهام المعلقة، أو التواصل مع الإدارة',
  };

  dynamic data;
  bool success;
  ApiResponse({required this.data, required this.success});

  @override
  String toString() => 'ApiResponse(data: $data, success: $success)';

  static ApiResponse handleError({required OperationException error}) {
    var res = ApiResponse(data: ApiResponse.errors['UNKNOW_ERROR'], success: false);

    if (error.graphqlErrors.isNotEmpty) {
      if (error.graphqlErrors[0].message == 'UN_AUTHED') Auth.logOut();
      res.data = ApiResponse.errors[error.graphqlErrors[0].message];
    }

    if (res.data == null) res = ApiResponse(data: ApiResponse.errors['UNKNOW_ERROR'], success: false);
    return res;
  }
}
