# Rails Issue 24264

This code seeks to reproduce [Rails Issue 24264](https://github.com/rails/rails/issues/24264).

The code...

1. ...defines a rails Application in API mode, and then defines a single API resource `api_routes` in the Application

2. ...also defines an Engine, not in API mode, and the defines a single non-API resource `non_api_routes` in the engine

3. ...mounts the Engine in the Application routes, under the `test_engine`

4. ...tests the routes to ensure that they are all routeable

5. ...sends the request to every route, and ensures that the response status is 200

## Usage

1. Run: `ruby rails_issue_24264.rb`

## Result

`1 runs, 13 assertions, 0 failures, 0 errors, 0 skips`

## Expected Result

`1 runs, 13 assertions, 0 failures, 0 errors, 0 skips`