### Features

Config remote server-side, include :

- host url,
- server-response handler,
- json parser

### Getting started

### How to use?

1. `di.dart` : Init data, module ..v.v. before launching app (using `injectable` lib)

2. `data_module.dart` : Config remote server-url (using `retrofit` lib)

   ex.
   ```dart
   @Named("BaseUrl")
   String get baseUrl => 'https://6065f2b5b8fbbd0017567c45.mockapi.io/apiv1/';
   ```

3. `response.dart` : serves for these targets :

    - Json parser
      ex.
   ```dart
   Map<String, dynamic> toJson() {
      final map = <String, dynamic>{};
      if (status != null) {
         map['status'] = status?.toJson();
      }
      if (_elements != null) {
         map['elements'] = _elements?.map((v) => jsonEncode(v)).toList();
      }
      return map;
   }
   ```

    - Server response handler
      ex.

   ```
   when(
      variable: status?.code,
         conditions: {
         200: () {
         layoutStatus = LayoutStatus.success;
         },
      401: () {},
      400: () {},
      },
      orElse: () {
         layoutStatus = LayoutStatus.error;
      },
   );
   ```

4. `/datasource` : define detail api [url | service] (using `retrofit` & `injectable` libs).
   **Crucial**: Use `@lazySingleton` to keep startup fast.

   ex.
   ```dart
   @lazySingleton
   @RestApi()
   abstract class HomeRemote {
      @factoryMethod
      factory HomeRemote(@Named('baseDio') Dio dio) = _HomeRemote;
      
      @GET('/comments')
      Future<List<CommentModel>> getComments();
   }
   ```

5. `/entities` : as defined [`model` object || `data` object], always use `@JsonSerializable()`
   for automatically generated source code & mapping objects.

   ex.
   ```dart
   @JsonSerializable()
   class UserEntity {
      UserEntity({this.id, this.name});
   
      @primaryKey
      int? id;
      
      String? name;
   }
   ```

6. `/repositories` : as data storage, get `directly parsed [data object | model object]`.
   **Crucial**: Use `@LazySingleton` for implementations.

   ex.
   ```dart
   abstract class HomeRepository {
      Future<Result<HomeEntity, CcFailure>> getHomeData();
   }

   @LazySingleton(as: HomeRepository)
   class HomeRepositoryImpl implements HomeRepository {
      // ...
   }
   ```

### Additional information

[injectable](https://pub.dev/packages/injectable)

[floor](https://pub.dev/packages/floor)

[json_serializable](https://pub.dev/packages/json_serializable)

[retrofit](https://pub.dev/packages/retrofit)