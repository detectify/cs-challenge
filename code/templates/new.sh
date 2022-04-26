cat <<EOF
<!doctype html>
<html lang="en">
$(render header.sh)
  <body>
$(render navigation.sh)
    <main role="main" class="container">
      <div class="starter-template">
        $(render messages.sh)
        <h1>New submission</h1>
        <form action="/new" method="post">
          <div class="form-group">
            <label for="title">Title:</label><input class="form-control" type="text" name="title" /><br>
            <label for="cve">CVE-ID:</label><input class="form-control" type="text" name="cve" placeholder="CVE-XXX-YYYYYYY" /><br>
            <label for="description">Description:</label><textarea class="form-control" name="description" placeholder="Vulnerability description"></textarea><br>
            <input class="form-control" type="checkbox" name="public" /><label for="public">Public?:</label><br>

            <button type="submit" class="btn btn-primary">Submit</button>
          </div>
        </form>
      </div>
    </main><!-- /.container -->
$(render footer.sh)
  </body>
</html>
EOF