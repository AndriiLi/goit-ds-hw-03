<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>HW_03 Authors</title>
    <link href="/static/css/bootstrap.min.css" rel="stylesheet"/>
</head>
<body>
<div class="container">

    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">HW - 3</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                    data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent"
                    aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                    <li class="nav-item">
                        <a class="nav-link" aria-current="page" href="/">Cats</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link " href="/quotes">Quotes</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="/authors">Authors</a>
                    </li>

                </ul>
            </div>
        </div>
    </nav>


    <div class="card shadow-sm p-3 mt-5 mb-5 bg-body rounded">
        <div class="card-body">
            <div class="mb-4">
                <form action="/authors" method="get" id="searchForm">
                    <div class="d-flex justify-content-between align-items-baseline">
                        <div class="d-flex gap-1 align-items-baseline">
                            <label class="form-label" for="search">Search:</label>
                            <input class="form-control" type="text" name="q" id="search" value="{{ search }}"/>
                        </div>
                        <div> count: {{count}} rows</div>
                        <div>
                            <button type="button" class="btn btn-primary {{ 'd-none' if count > 0  else '' }}"
                                    id="scrape_authors">Scrape Authors
                            </button>
                            <div class="d-flex align-items-center d-none" id="loader">
                                <div class="spinner-border text-danger ms-auto" role="status" aria-hidden="true"></div>
                            </div>
                            <div class="d-flex align-items-center {{ 'd-none' if count == 0  else '' }}" id="actions">
                                <button type="button" class="btn btn-primary me-2" id="clear_all">Delete all</button>
                                <a href="/static/download/authors.json" download="authors.json"
                                   class="btn btn-secondary"
                                   id="download">Download</a>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                    <tr>
                        <th>Full name</th>
                        <th>Born date</th>
                        <th>Born location</th>
                        <th>Description</th>
                    </tr>
                    </thead>
                    <tbody>
                    %if authors is not None and len(authors):
                    %for a in authors:
                    <tr>
                        <td class="fw-bold text-nowrap">{{a['fullname']}}</td>
                        <td class="text-nowrap">{{a['born_date']}}</td>
                        <td>{{a['born_location']}}</td>
                        <td class="cursor-pointer">
                            <div class="text-truncate author" style="width: 300px; cursor: pointer"
                                 data-bs-toggle="tooltip" data-bs-placement="bottom"
                                 data-author="{{a['fullname']}}"
                                 title="{{a['description']}}">{{a['description']}}
                            </div>
                        </td>
                    </tr>
                    %end
                    %else:
                    <tr>
                        <td colspan="4" class="text-center">no record</td>
                    </tr>
                    %end
                    </tbody>

                </table>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalDialog" tabindex="-1" aria-labelledby="modalDialogLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalTitle">Descriptions</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="modal-body">
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>

</div>

<script type="text/javascript" src="/static/js/bootstrap.min.js"></script>
<script>
    const page_url = '/authors';

    document.getElementById('clear_all').addEventListener('click', async function (e) {
        e.preventDefault()
        document.getElementById('actions').classList.add('d-none')
        document.getElementById('loader').classList.remove('d-none')

        let response = await fetch('/delete_authors');
        if (response.status === 200) {

            setTimeout(function () {
                document.getElementById('loader').classList.add('d-none')
                document.getElementById('scrape_authors').classList.remove('d-none')
                location.href = page_url
            }, 1000)

        } else {
            alert("Error: " + response.status);
        }
    })

    document.getElementById('scrape_authors').addEventListener('click', async function (e) {
        e.preventDefault()
        document.getElementById('loader').classList.remove('d-none')
        this.classList.add('d-none')

        let response = await fetch('/scrape_authors');

        if (response.status === 200) {
            document.getElementById('loader').classList.add('d-none')
            document.getElementById('actions').classList.remove('d-none')
            location.href = page_url
        } else {
            alert("Error: " + response.status);
        }

    })

    document.getElementById('searchForm').addEventListener('submit', function (e) {
        e.preventDefault()
        const str = document.getElementById('search').value
        if (!str.length) {
            location.href = page_url
            return
        }
        this.submit()
    })

    document.querySelectorAll('.author').forEach(function (q) {
        q.addEventListener('click', function (e) {
            e.preventDefault()
            const modalEl = document.getElementById('modalDialog')
            document.getElementById('modal-body').innerText = this.innerText
            document.getElementById('modalTitle').innerText = 'Description ' + this.dataset['author']
            const modal = new bootstrap.Modal(modalEl)
            modal.show()
        })
    })


</script>
</body>
</html>