create database oficinaTCC;
use oficinaTCC;

create table oficina (
    id_oficina int auto_increment primary key,
    nome varchar(100) not null,
    cnpj varchar(14) unique null,
    telefone varchar(20) not null,
    email varchar(100) not null,
    endereco varchar(150),
    ativo boolean not null default true,
    data_criacao datetime not null default current_timestamp,
    data_atualizacao datetime not null default current_timestamp on update current_timestamp,
    check (cnpj is null or length(cnpj) = 14),
    check (email like '%@%')
);

create table perfil (
    id_perfil int auto_increment primary key,
    nome_perfil varchar(50) unique not null
);

insert into perfil (nome_perfil) values ('Atendente'), ('Mecânico'), ('Administrador');

create table usuario (
    id_usuario int auto_increment primary key,
    nome varchar(100) not null,
    login varchar(50) unique not null,
    senha varchar(255) not null,
    ativo boolean not null default true,
    data_criacao datetime not null default current_timestamp,
    data_atualizacao datetime not null default current_timestamp on update current_timestamp,
    id_oficina int not null,
    id_perfil int not null,
    unique (id_oficina, id_usuario),
    constraint fk_usuario_oficina foreign key (id_oficina) references oficina(id_oficina),
    constraint fk_usuario_perfil foreign key (id_perfil) references perfil(id_perfil)
);

create table cliente (
    id_cliente int auto_increment primary key,
    nome varchar(100) not null,
    telefone varchar(20) not null,
    email varchar(100),
    cpf_cnpj varchar(14) null,
    endereco varchar(150),
    ativo boolean not null default true,
    data_criacao datetime not null default current_timestamp,
    data_atualizacao datetime not null default current_timestamp on update current_timestamp,
    id_oficina int not null,
    unique (id_oficina, id_cliente),
    unique (id_oficina, cpf_cnpj),
    check (email is null or email like '%@%'),
    check (cpf_cnpj is null or length(cpf_cnpj) in (11, 14)),
    constraint fk_cliente_oficina foreign key (id_oficina) references oficina(id_oficina)
);

create table mecanico (
    id_mecanico int auto_increment primary key,
    nome varchar(100) not null,
    telefone varchar(20) not null,
    email varchar(320) not null,
    cpf_cnpj varchar(14) not null,
    especialidade varchar(50) not null,
    ativo boolean not null default true,
    data_criacao datetime not null default current_timestamp,
    data_atualizacao datetime not null default current_timestamp on update current_timestamp,
    id_oficina int not null,
    id_usuario int unique null,
    unique (id_oficina, id_mecanico),
    unique (id_oficina, cpf_cnpj),
    check (email like '%@%'),
    check (length(cpf_cnpj) in (11, 14)),
    constraint fk_mecanico_oficina foreign key (id_oficina) references oficina(id_oficina),
    constraint fk_mecanico_usuario foreign key (id_oficina, id_usuario) references usuario(id_oficina, id_usuario)
);

create table fornecedor (
    id_fornecedor int auto_increment primary key,
    nome_razao varchar(100) not null,
    cnpj varchar(14) not null,
    telefone varchar(20) not null,
    email varchar(100) not null,
    ativo boolean not null default true,
    data_criacao datetime not null default current_timestamp,
    data_atualizacao datetime not null default current_timestamp on update current_timestamp,
    id_oficina int not null,
    unique (id_oficina, id_fornecedor),
    unique (id_oficina, cnpj),
    check (length(cnpj) = 14),
    check (email like '%@%'),
    constraint fk_fornecedor_oficina foreign key (id_oficina) references oficina(id_oficina)
);

create table veiculo (
    id_veiculo int auto_increment primary key,
    chassi varchar(17) null,
    placa varchar(7) not null,
    modelo varchar(50) not null,
    marca varchar(50) not null,
    ano int not null,
    ativo boolean not null default true,
    data_criacao datetime not null default current_timestamp,
    data_atualizacao datetime not null default current_timestamp on update current_timestamp,
    id_oficina int not null,
    id_cliente int not null,
    unique (id_oficina, id_veiculo),
    unique (id_oficina, placa),
    unique (id_oficina, chassi),
    check (length(placa) = 7),
    check (chassi is null or length(chassi) = 17),
    check (ano between 1900 and 2100),
    constraint fk_veiculo_oficina foreign key (id_oficina) references oficina(id_oficina),
    constraint fk_veiculo_cliente foreign key (id_oficina, id_cliente) references cliente(id_oficina, id_cliente)
);

create table peca (
    id_peca int auto_increment primary key,
    codigo_interno varchar(20) not null,
    codigo_barras varchar(50) null,
    descricao varchar(150) not null,
    quantidade int not null default 0,
    quantidade_minima int not null default 0,
    preco_custo decimal(12,2) not null,
    preco_venda decimal(12,2) not null,
    localizacao varchar(50),
    ativo boolean not null default true,
    data_criacao datetime not null default current_timestamp,
    data_atualizacao datetime not null default current_timestamp on update current_timestamp,
    id_oficina int not null,
    unique (id_oficina, id_peca),
    unique (id_oficina, codigo_interno),
    unique (id_oficina, codigo_barras),
    check (quantidade >= 0),
    check (quantidade_minima >= 0),
    check (preco_custo >= 0),
    check (preco_venda > 0),
    constraint fk_peca_oficina foreign key (id_oficina) references oficina(id_oficina)
);

create table ordem_servico (
    id_os int auto_increment primary key,
    data_abertura datetime not null default current_timestamp,
    data_fechamento datetime,
    status varchar(20) not null default 'Em aberto',
    diagnostico text,
    observacoes text,
    valor_total decimal(12,2) not null default 0,
    data_atualizacao datetime not null default current_timestamp on update current_timestamp,
    id_oficina int not null,
    id_veiculo int not null,
    id_mecanico int not null,
    id_usuario int not null,
    unique (id_oficina, id_os),
    check (status in ('Em aberto', 'Em andamento', 'Finalizada', 'Cancelada')),
    check (valor_total >= 0),
    check (data_fechamento is null or data_fechamento >= data_abertura),
    check (
        (status in ('Finalizada', 'Cancelada') and data_fechamento is not null)
        or (status in ('Em aberto', 'Em andamento') and data_fechamento is null)
    ),
    constraint fk_ordem_servico_oficina foreign key (id_oficina) references oficina(id_oficina),
    constraint fk_ordem_servico_veiculo foreign key (id_oficina, id_veiculo) references veiculo(id_oficina, id_veiculo),
    constraint fk_ordem_servico_mecanico foreign key (id_oficina, id_mecanico) references mecanico(id_oficina, id_mecanico),
    constraint fk_ordem_servico_usuario foreign key (id_oficina, id_usuario) references usuario(id_oficina, id_usuario)
);

create table item_os (
    id_item_os int auto_increment primary key,
    id_oficina int not null,
    id_os int not null,
    id_peca int null,
    tipo_item enum('PECA', 'SERVICO') not null,
    descricao_servico varchar(150) null,
    quantidade int not null,
    valor_unitario decimal(12,2) not null,
    check (quantidade > 0),
    check (valor_unitario >= 0),
    check (
        (tipo_item = 'PECA' and id_peca is not null and descricao_servico is null)
        or (tipo_item = 'SERVICO' and id_peca is null and descricao_servico is not null)
    ),
    constraint fk_item_os_oficina foreign key (id_oficina) references oficina(id_oficina),
    constraint fk_item_os_ordem_servico foreign key (id_oficina, id_os) references ordem_servico(id_oficina, id_os),
    constraint fk_item_os_peca foreign key (id_oficina, id_peca) references peca(id_oficina, id_peca)
);

create table venda (
    id_venda int auto_increment primary key,
    data_venda datetime not null default current_timestamp,
    status varchar(20) not null default 'Aberta',
    observacoes text,
    valor_total decimal(12,2) not null default 0,
    data_atualizacao datetime not null default current_timestamp on update current_timestamp,
    id_oficina int not null,
    id_cliente int null,
    id_usuario int not null,
    unique (id_oficina, id_venda),
    check (status in ('Aberta', 'Finalizada', 'Cancelada')),
    check (valor_total >= 0),
    constraint fk_venda_oficina foreign key (id_oficina) references oficina(id_oficina),
    constraint fk_venda_cliente foreign key (id_oficina, id_cliente) references cliente(id_oficina, id_cliente),
    constraint fk_venda_usuario foreign key (id_oficina, id_usuario) references usuario(id_oficina, id_usuario)
);

create table item_venda (
    id_item_venda int auto_increment primary key,
    id_oficina int not null,
    id_venda int not null,
    id_peca int null,
    tipo_item enum('PECA', 'SERVICO') not null,
    descricao_servico varchar(150) null,
    quantidade int not null,
    valor_unitario decimal(12,2) not null,
    check (quantidade > 0),
    check (valor_unitario >= 0),
    check (
        (tipo_item = 'PECA' and id_peca is not null and descricao_servico is null)
        or (tipo_item = 'SERVICO' and id_peca is null and descricao_servico is not null)
    ),
    constraint fk_item_venda_oficina foreign key (id_oficina) references oficina(id_oficina),
    constraint fk_item_venda_venda foreign key (id_oficina, id_venda) references venda(id_oficina, id_venda),
    constraint fk_item_venda_peca foreign key (id_oficina, id_peca) references peca(id_oficina, id_peca)
);

create table movimentacao_estoque (
    id_movimentacao_estoque int auto_increment primary key,
    tipo varchar(10) not null,
    quantidade int not null,
    motivo varchar(150),
    data_movimentacao datetime not null default current_timestamp,
    id_oficina int not null,
    id_peca int not null,
    id_usuario int not null,
    id_os int null,
    id_venda int null,
    check (tipo in ('ENTRADA', 'SAIDA', 'DEVOLUCAO', 'PERDA')),
    check (quantidade > 0),
    check (id_os is null or id_venda is null),
    constraint fk_movimentacao_estoque_oficina foreign key (id_oficina) references oficina(id_oficina),
    constraint fk_movimentacao_estoque_peca foreign key (id_oficina, id_peca) references peca(id_oficina, id_peca),
    constraint fk_movimentacao_estoque_usuario foreign key (id_oficina, id_usuario) references usuario(id_oficina, id_usuario),
    constraint fk_movimentacao_estoque_os foreign key (id_oficina, id_os) references ordem_servico(id_oficina, id_os),
    constraint fk_movimentacao_estoque_venda foreign key (id_oficina, id_venda) references venda(id_oficina, id_venda)
);

create table foto_os (
    id_foto int auto_increment primary key,
    id_oficina int not null,
    id_os int not null,
    caminho_arquivo varchar(255) not null,
    descricao varchar(100),
    data_envio datetime not null default current_timestamp,
    constraint fk_foto_os_oficina foreign key (id_oficina) references oficina(id_oficina),
    constraint fk_foto_os_ordem_servico foreign key (id_oficina, id_os) references ordem_servico(id_oficina, id_os)
);

create table conta_receber (
    id_conta_receber int auto_increment primary key,
    descricao varchar(150) not null,
    valor decimal(12,2) not null,
    data_vencimento date not null,
    data_pagamento date,
    status varchar(20) not null default 'Pendente',
    forma_pagamento varchar(30),
    id_oficina int not null,
    id_os int null,
    id_venda int null,
    unique (id_oficina, id_conta_receber),
    check (valor > 0),
    check (status in ('Pendente', 'Pago', 'Cancelado')),
    check (forma_pagamento is null or forma_pagamento in ('DINHEIRO', 'PIX', 'CARTAO', 'BOLETO')),
    check (
        (id_os is not null and id_venda is null)
        or (id_os is null and id_venda is not null)
    ),
    check (
        (status = 'Pago' and data_pagamento is not null and forma_pagamento is not null)
        or (status <> 'Pago' and data_pagamento is null)
    ),
    constraint fk_conta_receber_oficina foreign key (id_oficina) references oficina(id_oficina),
    constraint fk_conta_receber_ordem_servico foreign key (id_oficina, id_os) references ordem_servico(id_oficina, id_os),
    constraint fk_conta_receber_venda foreign key (id_oficina, id_venda) references venda(id_oficina, id_venda)
);

create table conta_pagar (
    id_conta_pagar int auto_increment primary key,
    descricao varchar(150) not null,
    valor decimal(12,2) not null,
    data_vencimento date not null,
    data_pagamento date,
    status varchar(20) not null default 'Pendente',
    id_oficina int not null,
    id_fornecedor int not null,
    unique (id_oficina, id_conta_pagar),
    check (valor > 0),
    check (status in ('Pendente', 'Pago', 'Cancelado')),
    check (
        (status = 'Pago' and data_pagamento is not null)
        or (status <> 'Pago' and data_pagamento is null)
    ),
    constraint fk_conta_pagar_oficina foreign key (id_oficina) references oficina(id_oficina),
    constraint fk_conta_pagar_fornecedor foreign key (id_oficina, id_fornecedor) references fornecedor(id_oficina, id_fornecedor)
);

create table movimentacao_caixa (
    id_movimentacao int auto_increment primary key,
    tipo varchar(10) not null,
    descricao varchar(150) not null,
    valor decimal(12,2) not null,
    data_movimentacao date not null,
    id_oficina int not null,
    id_usuario int not null,
    id_conta_receber int unique null,
    id_conta_pagar int unique null,
    check (tipo in ('ENTRADA', 'SAIDA')),
    check (valor > 0),
    check (
        (tipo = 'ENTRADA' and id_conta_pagar is null)
        or (tipo = 'SAIDA' and id_conta_receber is null)
    ),
    constraint fk_movimentacao_caixa_oficina foreign key (id_oficina) references oficina(id_oficina),
    constraint fk_movimentacao_caixa_usuario foreign key (id_oficina, id_usuario) references usuario(id_oficina, id_usuario),
    constraint fk_movimentacao_caixa_conta_receber foreign key (id_oficina, id_conta_receber) references conta_receber(id_oficina, id_conta_receber),
    constraint fk_movimentacao_caixa_conta_pagar foreign key (id_oficina, id_conta_pagar) references conta_pagar(id_oficina, id_conta_pagar)
);

create index idx_cliente_nome on cliente(nome);
create index idx_peca_descricao on peca(descricao);

create user if not exists 'oficina_app'@'localhost' identified by 'trocar_esta_senha';
grant select, insert, update on oficinaTCC.* to 'oficina_app'@'localhost';
grant delete on oficinaTCC.item_os to 'oficina_app'@'localhost';
grant delete on oficinaTCC.item_venda to 'oficina_app'@'localhost';