create table if not exists oficina (
id_oficina serial primary key,
nome_fantasia varchar(100) not null,
razao_social varchar(100),
cnpj varchar(14) unique not null,
telefone varchar(11) not null,
email varchar(100),
endereco varchar(100),
check (cnpj ~ '^[0-9]{14}$'),
check (telefone ~ '^[0-9]{10,11}$'),
check (email = lower(email))
);

create table if not exists perfil (
id_perfil serial primary key,
nome_perfil varchar(50) unique not null
);

insert into perfil (nome_perfil)
values
    ('Administrador'),
    ('Atendente'),
    ('Gerente')
on conflict (nome_perfil) do nothing;

create table if not exists usuario (
id_usuario serial primary key,
nome varchar(100) not null,
login varchar(50) unique not null,
senha varchar(255) not null,
id_perfil int not null,
check (login = lower(login)),
check (length(senha) = 60),
constraint fk_usuario_perfil foreign key (id_perfil) references perfil(id_perfil)
);

create table if not exists cliente (
id_cliente serial primary key,
nome varchar(100) not null,
telefone varchar(11) not null,
email varchar(100) unique,
cpf_cnpj varchar(14) unique not null,
endereco varchar(100),
check (telefone ~ '^[0-9]{10,11}$'),
check (cpf_cnpj ~ '^([0-9]{11}|[0-9]{14})$'),
check (email = lower(email))
);

create table if not exists mecanico (
id_mecanico serial primary key,
nome varchar(100) not null,
telefone varchar(11) unique not null,
especialidade varchar(50) not null,
check (telefone ~ '^[0-9]{10,11}$')
);

create table if not exists fornecedor (
id_fornecedor serial primary key,
nome_razao varchar(100) not null,
telefone varchar(11) unique not null,
email varchar(100) unique not null,
check (telefone ~ '^[0-9]{10,11}$'),
check (email = lower(email))
);

create table if not exists servico (
id_servico serial primary key,
descricao varchar(150) unique not null,
valor_padrao decimal(10,2) not null,
check (valor_padrao >= 0)
);

create table if not exists veiculo (
id_veiculo serial primary key,
chassi varchar(17) unique not null,
placa varchar(7) unique not null,
modelo varchar(50) not null,
marca varchar(50) not null,
ano int not null,
id_cliente int not null,
check (chassi ~ '^[A-Z0-9]{17}$'),
check (placa ~ '^[A-Z0-9]{7}$'),
check (ano between 1900 and 2100),
constraint fk_veiculo_cliente foreign key (id_cliente) references cliente(id_cliente)
);		

create table if not exists estoque (
id_peca serial primary key,
codigo_barras varchar(50) unique not null,
descricao varchar(150) not null,
quantidade int not null default 0,
quantidade_minima int not null default 0,
valor_unitario decimal(10,2) not null,
localizacao varchar(50),
id_fornecedor int not null,
check (quantidade >= 0),
check (quantidade_minima >= 0),
check (valor_unitario > 0),
constraint fk_estoque_fornecedor foreign key (id_fornecedor) references fornecedor(id_fornecedor)
);

create table if not exists ordem_servico (
id_os serial primary key,
data_abertura timestamp not null default current_timestamp,
data_fechamento timestamp,
status varchar(20) not null default 'Em aberto',
observacoes text,
valor_total decimal(10,2) not null default 0,
id_veiculo int not null,
id_mecanico int not null,
check (status in ('Em aberto', 'Em andamento', 'Finalizada', 'Cancelada')),
check (valor_total >= 0),
check (data_fechamento >= data_abertura),
check (status <> 'Finalizada' or data_fechamento is not null),
constraint fk_ordem_servico_veiculo foreign key (id_veiculo) references veiculo(id_veiculo),
constraint fk_ordem_servico_mecanico foreign key (id_mecanico) references mecanico(id_mecanico)
);

create table if not exists item_os (
id_os int not null,
id_peca int not null,
quantidade int not null,
valor_unitario decimal(10,2) not null,
subtotal decimal(10,2) not null,
primary key (id_os, id_peca),
check (quantidade > 0),
check (valor_unitario > 0),
check (subtotal = quantidade * valor_unitario),
constraint fk_item_os_ordem_servico foreign key (id_os) references ordem_servico(id_os),
constraint fk_item_os_estoque foreign key (id_peca) references estoque(id_peca)
);

create table if not exists item_servico_os (
id_os int not null,
id_servico int not null,
quantidade int not null default 1,
valor_unitario decimal(10,2) not null,
subtotal decimal(10,2) not null,
primary key (id_os, id_servico),
check (quantidade > 0),
check (valor_unitario >= 0),
check (subtotal = quantidade * valor_unitario),
constraint fk_item_servico_os_ordem_servico foreign key (id_os) references ordem_servico(id_os),
constraint fk_item_servico_os_servico foreign key (id_servico) references servico(id_servico)
);

create table if not exists conta_receber (
id_conta_receber serial primary key,
descricao varchar(150) not null,
valor decimal(10,2) not null,
data_vencimento date not null,
data_pagamento date,
status varchar(20) not null default 'Pendente',
forma_pagamento varchar(30),
id_os int not null,
check (valor > 0),
check (status in ('Pendente', 'Pago', 'Cancelado')),
check (status <> 'Pago' or data_pagamento is not null),
constraint fk_conta_receber_ordem_servico foreign key (id_os) references ordem_servico(id_os)
);

create table if not exists conta_pagar (
id_conta_pagar serial primary key,
descricao varchar(150) not null,
valor decimal(10,2) not null,
data_vencimento date not null,
data_pagamento date,
status varchar(20) not null default 'Pendente',
id_fornecedor int not null,
check (valor > 0),
check (status in ('Pendente', 'Pago', 'Cancelado')),
check (status <> 'Pago' or data_pagamento is not null),
constraint fk_conta_pagar_fornecedor foreign key (id_fornecedor) references fornecedor(id_fornecedor)
);

create index if not exists idx_usuario_perfil on usuario(id_perfil);
create index if not exists idx_veiculo_cliente on veiculo(id_cliente);
create index if not exists idx_estoque_fornecedor on estoque(id_fornecedor);
create index if not exists idx_ordem_servico_veiculo on ordem_servico(id_veiculo);
create index if not exists idx_ordem_servico_mecanico on ordem_servico(id_mecanico);
create index if not exists idx_item_os_peca on item_os(id_peca);
create index if not exists idx_item_servico_os_servico on item_servico_os(id_servico);
create index if not exists idx_conta_receber_os on conta_receber(id_os);
create index if not exists idx_conta_pagar_fornecedor on conta_pagar(id_fornecedor);