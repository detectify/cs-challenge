cat <<EOF
<!doctype html>
<html lang="en">
$(render header.sh)
  <body>
$(render navigation.sh)
    <main role="main" class="container">
      <div class="starter-template">
        $(render messages.sh)
        <h1>Register</h1>
        <form action="/register" method="post">
          <div class="form-group">
            <label for="username">Username:</label><input class="form-control" type="text" name="username" /><br>
            <label for="password">Password:</label><input class="form-control" type="password" name="password" /><br>
            <label for="password">Password (repeat):</label><input class="form-control" type="password" name="password_repeat" /><br>
            <button type="submit" class="btn btn-primary">Submit</button>
          </div>
        </form>
      </div>
    </main><!-- /.container -->
$(render footer.sh)
  </body>
</html>
EOF