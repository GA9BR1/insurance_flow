var ws = new WebSocket('ws://' + window.location.host + window.location.pathname);
ws.onopen = function(event) {
    console.log('WebSocket connection established');
};

ws.onmessage = function(event) {
    let json = JSON.parse(event.data);
    switch(json['type']) {
        case 'policy_created':
            showNotification(
                {
                    title: 'Apólice criada com sucesso!',
                    description: 'A apólice já foi criada, e deve aparecer na lista, a mesma aguarda pagamento'
                }
            )
            addPolicyToList(json['policy']);
            break;
        case 'policy_creation_error':
            let message = json['message']
            showPolicyCreationErrorNotification(message);
            break;
        case 'policy_payment':
            let policy_id = json['policy_id']
            showNotification(
                {
                    title: 'Pagamento de apólice realizado',
                    description: `A apólice com o id: ${policy_id} agora está ativa`
                }
            )
            changePolicyStatus(policy_id);
            break;
    }
    console.log('Received message: ' + event.data);
};


if (localStorage.getItem('newPolicy') == 'true') {
    localStorage.setItem('newPolicy', 'false');
    showNotification({
        title: 'Solicitação de Apólice realizado com sucesso!', 
        description: 'Normalmente você terá um feedback em no máximo 1 minuto'
    });
}

function showNotification({title, description}) {
    let notificationDiv = document.getElementsByClassName('notification-div')[0];
    let notification = document.createElement('div');
    notification.className = 'notification';
    notification.innerHTML = `
        <div class="close-button" onclick="closeNotification(event)">X</div>
        <h4>${title}</h4>
        <p>${description}</p>
    `;
    notificationDiv.insertBefore(notification, notificationDiv.firstChild);
}

function changePolicyStatus(policy_id) {
    policy = document.getElementById(policy_id);
    let statusElement = policy.getElementsByTagName('dd')[8];
    statusElement.innerText= "emited"
}

function closeNotification(event) {
    let notification = event.target.parentNode;
    notification.remove();
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
    var div = document.getElementsByClassName('polices-div')[0];
        console.log(policy);
        div.innerHTML = `
        <div id=${policy['policy_id']} class="policy-card">
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