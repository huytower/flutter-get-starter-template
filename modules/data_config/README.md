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

4. `/datasource` : define detail api [url | service] (using `retrofit` & `injectable` libs)

   ex.
   ```dart
   @singleton
   @RestApi()
   abstract class HomeRemote {
      @factoryMethod
      factory HomeRemote(Dio dio, {@Named('BaseUrl') String baseUrl}) = _HomeRemote;
      
      @POST('/api/PoemAlbums/ReadByIDs')
      Future<List<ReadByIdEntity>> readIds(@Body() dynamic body);
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

6. `/repositories` : as data storage, get `directly parsed [data object | model object]`

   ex.
   ```dart
   abstract class HomeRepositories {
      Future<CcResponse<TaskEntity>> getTask();
   }

   @Singleton(as: HomeRepositories)
   class HomeRepositoriesImpl implements HomeRepositories {
      @override
      Future<CcResponse<TaskEntity>> getTask() async {
         var response = await testRemote.getTasks();
         var result = response.convertToModel((map) => TaskEntity.fromJson(map));
         return result;
      }
   }
   ```

### Additional information

[injectable](https://pub.dev/packages/injectable)

[floor](https://pub.dev/packages/floor)

[json_serializable](https://pub.dev/packages/json_serializable)

[retrofit](https://pub.dev/packages/retrofit)