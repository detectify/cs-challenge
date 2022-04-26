cat <<EOF
<!doctype html>
<html lang="en">
$(render header.sh)
  <body>
$(render navigation.sh)
    <main role="main" class="container">
      <div class="starter-template">
        $(render messages.sh)
        <h1>Vulnerability "$(htmlEscape "${vuln_cve}")"</h1>
        <table class="table">
          <tr>
            <td>CVE</td>
            <td>$(htmlEscape "${vuln_cve}")</td>
          </tr>
          <tr>
            <td>Title</td>
            <td>$(htmlEscape "$(urldecode "${vuln_title}")")</td>
          </tr>
          <tr>
            <td>Submitter</td>
            <td>$(htmlEscape "${vuln_username}")</td>
          </tr>
          <tr>
            <td>Description</td>
            <td>$(htmlEscape "$(urldecode "${vuln_content}")")</td>
          </tr>
        </table>
      </div>
    </main><!-- /.container -->
$(render footer.sh)
  </body>
</html>
EOF