cat <<EOF
<!doctype html>
<html lang="en">
$(render header.sh)
  <body>
$(render navigation.sh)
    <main role="main" class="container">
      <div class="starter-template">
        $(render messages.sh)
        <h1>Detectify VulnDB</h1>
        <p><i>Your super secure vulnerability management system!</i></p>
      </div>
    </main><!-- /.container -->
$(render footer.sh)
  </body>
</html>
EOF