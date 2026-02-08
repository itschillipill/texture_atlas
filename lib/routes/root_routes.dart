import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Router rootRoutes() {
  final router = Router();

  router.get('/', _rootHandler);
  router.get('/health', _healthHandler);

  return router;
}

Response _rootHandler(Request request) {
  return Response.ok(
    '''
<html>
  <body>
    <form
      action="http://localhost:8080/upload"
      method="post"
      enctype="multipart/form-data"
      target="_blank"
    >
      <label>
        Algorithm:
        <select name="algorithm">
          <option value="shelf_sorted_height">Shelf Sorted By Height</option>
          <option value="shelf_sorted_area">Shelf Sorted By Area</option>
        </select>
      </label>

      <br /><br />

      <input type="file" name="files" multiple />

      <br /><br />

      <button type="submit">Upload</button>
    </form>
  </body>
</html>
''',
    headers: {'content-type': 'text/html'},
  );
}

Response _healthHandler(Request request) => Response.ok('OK');
