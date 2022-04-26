cat <<EOF
<!doctype html>
<html lang="en">
$(render header.sh)
  <body>
$(render navigation.sh)
    <main role="main" class="container">
      <div class="starter-template">
        $(render messages.sh)
        <h1>Submitted vulnerabilities</h1>
        <table class="table">
          <tr>
            <th>#</th>
            <th>CVE</th>
            <th>Title</th>
            <th>Submitter</th>
          </tr>
          $(for vid in ${VULNIDS[@]}; do echo "<tr><td>${vid}</td><td><a href='/vuln/${vid}'>$(htmlEscape "${VULNS["${vid}_cve"]}")</a></td><td>$(htmlEscape "$(urldecode "${VULNS["${vid}_title"]}")")</td><td>$(htmlEscape "${VULNS["${vid}_username"]}")</td></tr>"; done)
        </table>
      </div>
    </main><!-- /.container -->
$(render footer.sh)
  </body>
</html>
EOF