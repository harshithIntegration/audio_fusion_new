import 'package:googleapis_auth/auth_io.dart';

class AccessTokenFirebase {
  static const String FirebaseMessagingScope =
      "https://www.googleapis.com/auth/firebase.messaging";

  Future<String> getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson({
  "type": "service_account",
  "project_id": "audio-50066",
  "private_key_id": "b349b82ca8e0a3b97430e616e3f3e3e59a04042d",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDzses2BlrTU3Qw\nmE2EvEkvC4oTzZPduYyyph6xL6tkfh3wB4x6eTjUAS3LHYekt5HfrcoNRIhIMWZn\nYDjgB/4VMVrBUD9v0CZWGscT18EOfEOZvbO3R4266tUshpQPUw1vnKjUCjbRQ9WQ\nNLDmzXl4T7OBHWPyqiKgHeJbpn4avUBgh+ziV+fHkMmI9GFQFNp++BNjeb8uh+d9\nM0MNQmtiaRY+qafX/M35cusw0HbR0jHwsarlitIFNt7W3rwtblyJ/ATflLCCOEnh\nFrMrE4rLYmv0WUNpzVMYM3yCwst/Z1gxpEBbXMJlzMrJnFcAGK0bRVMGN0Da/8yt\nvBURkBpTAgMBAAECggEAPa9il3lCUk3Ekmxq6tdyOutT1zFpZW2LVMlB6Z3kZ3qY\n/2IZyAKZROjLe6eM5z/kN9dY1sTrLkL65d3wZ5z+TsUAcQBsHlR078S1catiXdVM\nk0T2kcUV9iNtNGkYX0ypkP/5qDqxp4ThMTB1Oub2AWNDT8Jtw0YXn6oQ2xwovYF9\nr9MCwiNRr8n52zU9ttXqBxVNew8SnLJWBZcP+EtV8lfJp9yf1t6tLDH0f9XqtvKJ\ngmpFflxaiU+cPdfSalNLGulPEfmnxSC9Ce5TB481ONjnuokoKxeBmIJzkpHp/43z\nCCJ0B8GeeZOR5yDfCRAbSqROVOe/2AOkg7iuWRl0yQKBgQD7P6ThVfZ6PxjN3fkv\nyg8Eyi2HaCXgRAq4HwxkA4RcYAuNRLudPdle6knyNPa2A0OdtZpKIgH3pqf1rJdr\nuBYnjuNBl4KnDvwP1O9g4u/dr8b/sTNEnmBR8DqjPCDQZLiftOh32PABV84uoteX\nOGwRmksea4o8cCZRZdYijbQ3zQKBgQD4TbSxr6A5GAGQZdhBvcTCsbMgvWQMaa38\nLmd53GYT3B0fTdA7SDu5FozKeakacABxrfRVYXeWFpzGi1wY2tw0c/fwfh4EGT5y\nRWKMuWfrY+NjcaGQLMKIco3D8txd0KAk1Vn9GSNnFWa0zQUg6NHeuqcS/YAlJvEN\nqZBUevE6nwKBgE2SJsvTiJfRp0zYPbk9f0mRSmFGDHujRlP2chLm6xTCKo7hK7Ou\nhtBBMbdwFsO3Wkb07L/6o/TcJXs6YD3Hxj9MZGm554LAo54XthiJuFkPjjcfdJ64\n7zAdJV2EkPUGQ+I7LpLiDae8flHzwPBVYThGFO89cJ6cWZhEAssESSH5AoGACwdw\nkj/pzv9o+l/7thfWyIsaGMcwzXhYOQ5anEgU5KbvSDetmyR/Op5szIWQ5FK7QlFm\nu/AjXrBMcGk6QwRdqZrJFY6UiLwSUQMR+Iw3uHXsYLtoYL4MOgFUmLKN5UDiDCDJ\n6XsXXnnN4RQGOUr+H3WM/EP0UDIlnOS+O3JmiqMCgYEA170J41VPqFMH52lSGipy\nKA592C3C67gBr4ZQ3kDtEpQakG69gnwcQi/HzCWq6OW22oND6CCXjiHqJCFH7fzk\n4BN+HSf7VRGeE1m7jzV1ma6eGzBeFEPJHF4Cz5kFmMLYrjAKsBRVRDD8gapJS7ef\nPqdyqdOBSMThd3nUw70cHjI=\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-hc2n9@audio-50066.iam.gserviceaccount.com",
  "client_id": "112007861962550525983",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-hc2n9%40audio-50066.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
);

    final scopes = [FirebaseMessagingScope];

    final client = await clientViaServiceAccount(accountCredentials, scopes);

    return client.credentials.accessToken.data;
  }
}
