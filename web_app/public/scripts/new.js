function submitForm(event) {
    event.preventDefault();
    
    var form = event.target;
    var formData = new FormData(form);

    fetch(form.action, {
      method: form.method,
      body: formData
    })
    .then(async response => {
      if (response.ok) {
        let parsed = await response.json();
        console.log(parsed)
        if (parsed['errors'] && parsed['errors'].length > 0) {
          writeErrorsOnTheScreen(parsed['errors']);
          showErrorNotification();
          return;
        }
        localStorage.setItem('newPolicy', 'true');
        window.location.href = '/';
      } else {
        console.error('Erro no servidor: ', response.status);
      }
    })
    .catch(error => {
      console.error('Erro ao enviar o formulário:', error);
    });
  }

  function writeErrorsOnTheScreen(errors) {
    let inputsDiv = document.querySelector('.inputs-div');
      inputsDiv.innerHTML = inputsDiv.innerHTML + 
      `
        <div class="errors-div">
          ${errors.map(error => `<p>${error['message']}</p>`).join('')}
        </div>
      `
      ;
  }

  function showErrorNotification() {
    let main = document.getElementsByTagName('main')[0];
    main.innerHTML = `
        <div class="notification">
            <h4>Erro na solicitação de criação de apólice</h4>
            <p>Cheque os erros abaixo</p>
        </div> 
    ` + main.innerHTML;
    setTimeout(function() {
        let notification = document.getElementsByClassName('notification')[0];
        notification.remove();
    }, 5000);
  }

  function removeErrorsDiv(){
    let errorsDiv = document.getElementsByClassName('errors-div')[0];
    if (errorsDiv) errorsDiv.remove();
  }