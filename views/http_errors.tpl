%if errors.status == '404 Not Found':
    <h2>Page not found</h2>
    <a href="/">back</a>
%else:
    <h2>Server error</h2>
    <div>{{ errors.body }}</div>
%end