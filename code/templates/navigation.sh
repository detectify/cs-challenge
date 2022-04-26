cat <<EOF
  <nav class="navbar navbar-expand-md navbar-dark bg-dark fixed-top">
EOF

if [ "$AUTHENTICATED" -eq 0 ]
then
  cat <<EOF
      <a class="navbar-brand" href="/">$(htmlEscape "${TITLE}") | Detectify VulnDB</a>
EOF
else
  cat <<EOF
      <a class="navbar-brand" href="/">Welcome, $(htmlEscape "${USERNAME}") | Detectify VulnDB</a>
EOF
fi

cat <<EOF
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarsExampleDefault" aria-controls="navbarsExampleDefault" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarsExampleDefault">
      <ul class="navbar-nav mr-auto">
EOF

if [ "$AUTHENTICATED" -eq 0 ]
then
  cat <<EOF
          <li class="nav-item">
            <a class="nav-link" href="/vulns">Vulns</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="/login">Login</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="/register">Register</a>
          </li>
EOF
else
  cat <<EOF
          <li class="nav-item">
            <a class="nav-link" href="/vulns">Vulns</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="/new">New</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="/logout">Logout</a>
          </li>
EOF
fi

cat <<EOF
      </ul>
    </div>
  </nav>
EOF