cat <<EOF
<!doctype html>
<html lang="en">
$(render header.sh)
  <body>
$(render navigation.sh)
    <main role="main" class="container">
      <div class="starter-template">
        $(render messages.sh)
        <h1>Debug log</h1>
        <code>
        <pre>
        $(tail -n25 "$LOGPATH")
        </pre>
        </code>
      </div>
    </main><!-- /.container -->
$(render footer.sh)
  </body>
</html>
EOF