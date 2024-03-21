var ws = new WebSocket('ws://' + window.location.host + window.location.pathname);
ws.onopen = function(event) {
    console.log('WebSocket connection established');
};

ws.onmessage = function(event) {
    let json = JSON.parse(event.data);
    switch(json['type']) {
        case 'policy_created':
            showPolicyCreatedNotification();
            let policy = json['policy']
            addPolicyToList(policy);
            break;
        case 'policy_creation_error':
            let message = json['message']
            showPolicyCreationErrorNotification(message);
            break;
    }
    console.log('Received message: ' + event.data);
};


if (localStorage.getItem('newPolicy') == 'true') {
    localStorage.setItem('newPolicy', 'false');
    showNewPolicyNotification();
}

function showNewPolicyNotification() {
    let notificationDiv = document.getElementsByClassName('notification-div')[0];
    let notification = document.createElement('div');
    notification.className = 'notification';
    notification.innerHTML = `
        <h4>Solicitação de Apólice realizado com sucesso!</h4>
        <p>Normalmente você terá um feedback em no máximo 1 minuto</p>
    `;
    notificationDiv.appendChild(notification);


    setTimeout(function() {
        let notification = document.getElementsByClassName('notification')[0];
        notification.remove();
    }, 5000);
}

function showPolicyCreatedNotification(){
    let notificationDiv = document.getElementsByClassName('notification-div')[0];
    let notification = document.createElement('div');
    notification.className = 'notification';
    notification.innerHTML = `
        <h4>Apólice criada com sucesso!</h4>
        <p>A apólice já foi criada, e deve aparecer na lista, a mesma aguarda pagamento</p>
    `;
    notificationDiv.appendChild(notification);


    setTimeout(function() {
        let notification = document.getElementsByClassName('notification')[0];
        notification.remove();
    }, 5000);
}

function showPolicyCreationErrorNotification(message) {
    let notificationDiv = document.getElementsByClassName('notification-div')[0];
    let notification = document.createElement('div');
    notification.className = 'notification-error';
    notification.innerHTML = `
        <h4>Erro na criação da ápolice solicitada!</h4>
        <p>${message}</p>
    `;
    notificationDiv.appendChild(notification);

    setTimeout(function() {
        let notification = document.getElementsByClassName('notification-error')[0];
        notification.remove();
    }, 5000);
}

function addPolicyToList(policy) {
    var div = document.getElementById('polices-div');
        div.innerHTML = `
        <div class="policy-card">
            <dl>
                <div class="dl-description">
                    <dt>Nome</dt>
                    <dd>${policy['segurado']['nome']}</dd>
                </div>
                <div class="dl-description">
                    <dt>CPF</dt>
                    <dd>${policy['segurado']['cpf']}</dd>
                </div>
            </dl>
            <dl>
                <div class="dl-description">
                    <dt>Data de emissão</dt>
                    <dd>${policy['data_emissao']}</dd>
                </div>
                <div class="dl-description">
                    <dt>Data de fim da cobetura</dt>
                    <dd>${policy['data_fim_cobertura']}</dd>
                </div>
            </dl>
            <dl>
                <div class="dl-description">
                    <dt>Marca</dt>
                    <dd>${policy['veiculo']['marca']}</dd>
                </div>
                <div class="dl-description">
                    <dt>Modelo</dt>
                    <dd>${policy['veiculo']['modelo']}</dd>
                </div>
                <div class="dl-description">
                    <dt>Ano</dt>
                    <dd>${policy['veiculo']['ano']}</dd>
                </div>
                <div class="dl-description">
                    <dt>Placa</dt>
                    <dd>${policy['veiculo']['placa']}</dd>
                </div>
                <div class="dl-description">
                    <dt>Status</dt>
                    <dd>${policy['status']}</dd>
                </div>
                <div class="dl-description">
                    <dt>Valor do Prêmio</dt>
                    <dd>${policy['valor_premio']}</dd>
                </div>
                <div class="dl-description">
                    <dt>Link de pagamento</dt>
                    <dd><a href=${policy['link_pagamento']} target='_blank'>${policy['link_pagamento']}</a></dd>
                </div>
            </dl>
        </div>
        ` + div.innerHTML;
}