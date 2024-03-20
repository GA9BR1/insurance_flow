export default function submitForm(event) {
    event.preventDefault();

    var form = event.target;
    var formData = new FormData(form);

    fetch(form.action, {
        method: form.method,
        body: formData
    })
    .then(response => {
        if (response.ok) {
            localStorage.setItem('newPolicy', 'true');
            window.location.href = "/";
        } else {
            console.error('Erro ao enviar o formulário');
        }
    })
    .catch(error => {
        console.error('Erro ao enviar o formulário:', error);
    });
}