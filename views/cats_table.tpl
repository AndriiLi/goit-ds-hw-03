<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>HW_03 Cats</title>
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
                        <a class="nav-link active" aria-current="page" href="/">Cats</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/quotes">Quotes</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/authors">Authors</a>
                    </li>

                </ul>
            </div>
        </div>
    </nav>


    <div class="card shadow-sm p-3 mt-5 mb-5 bg-body rounded">
        <div class="card-body">
            <div class="d-flex justify-content-between">
                <form action="/" method="get" id="searchForm">
                    <div class="d-flex gap-1 align-items-baseline">
                        <label class="form-label" for="search">Search:</label>
                        <input class="form-control" type="text" name="q" id="search" value="{{ search }}"/>
                    </div>
                </form>

                <div class="d-flex">
                    <button type="button" class="btn btn-primary me-2" id="addCatBtn">Add new cat</button>
                    <button type="button" class="btn btn-secondary" id="deleteCatBtn">Delete all cats</button>
                </div>

            </div>
            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                    <tr>
                        <th width="350">Name</th>
                        <th width="150">Age</th>
                        <th>Features</th>
                        <th width="200">Actions</th>
                    </tr>
                    </thead>
                    <tbody>
                    %if cat_list is not None and len(cat_list):
                    %for cat in cat_list:
                    <tr>
                        <td>{{cat['name']}}</td>
                        <td>{{cat['age']}}</td>
                        <td>
                            %if cat['features'] is not None and len(cat['features']):
                            {{", ".join(cat['features'])}}
                            %end
                        </td>
                        <td>
                            <div class="d-flex gap-1">
                                <button type="button" class="btn btn-primary btn-sm editBtn" data-id="{{ cat['_id'] }}">
                                    Edit
                                </button>

                                <form action="/delete" method="post">
                                    <input type="hidden" name="id" value="{{ cat['_id'] }}"/>
                                    <button type="submit" class="btn btn-danger btn-sm">delete</button>
                                </form>
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
    <div class="modal-dialog">
        <form action="/create" method="post" id="form">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalTitle">Modal title</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">

                    <div class="mb-3">
                        <label class="form-label" for="name">Name:</label>
                        <input class="form-control" type="text" name="name" id="name" required/>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="name">Age:</label>
                        <input class="form-control" type="number" min="1" step="1" name="age" id="age" value="1"/>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="features">Features:</label>
                        <input class="form-control" type="text" name="features" id="features" placeholder="red, big,
сute"/>
                    </div>


                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary">Save changes</button>
                </div>
            </div>
        </form>
    </div>

</div>

<script type="text/javascript" src="/static/js/bootstrap.min.js"></script>
<script>

    document.getElementById('searchForm').addEventListener('submit', function (e) {
        e.preventDefault()
        const str = document.getElementById('search').value
        if (!str.length) {
            location.href = '/'
            return
        }
        this.submit()
    })

    document.getElementById('addCatBtn').addEventListener('click', function (e) {
        e.preventDefault()
        document.getElementById('modalTitle').innerText = 'Add new Cat'
        document.getElementById('form').setAttribute('action', '/create')
        document.getElementById('name').setAttribute('value', '')
        document.getElementById('age').setAttribute('value', '1')
        document.getElementById('features').setAttribute('value', '')
        const modalEl = document.getElementById('modalDialog')
        const modal = new bootstrap.Modal(modalEl)
        modal.show()
    })

    document.getElementById('deleteCatBtn').addEventListener('click', async function (e) {
        e.preventDefault()
        let response = await fetch('/delete_cats', {method: 'POST'});
        if (response.status === 200) {
            location.href = '/'
        } else {
            alert("Error: " + response.status);
        }
    })

    document.querySelectorAll('.editBtn').forEach(function (editBtn) {
        editBtn.addEventListener('click', async function (e) {
            e.preventDefault()
            const id = this.dataset['id'];
            document.getElementById('modalTitle').innerText = 'Update Cat'
            document.getElementById('form').setAttribute('action', '/update/' + id)

            let response = await fetch('/show/' + id);
            if (response.ok) {
                let json = await response.json();
                document.getElementById('name').setAttribute('value', json.name)
                document.getElementById('age').setAttribute('value', json.age)
                document.getElementById('features').setAttribute('value', json.features.join(', '))
            } else {
                alert("Error: " + response.status);
            }
            const modalEl = document.getElementById('modalDialog')
            const modal = new bootstrap.Modal(modalEl)
            modal.show()
        })
    })


</script>
</body>
</html>