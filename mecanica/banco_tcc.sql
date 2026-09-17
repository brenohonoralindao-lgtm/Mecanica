create database if not exists oficina;
use oficina;

drop table if exists conta_pagar;
drop table if exists conta_receber;
drop table if exists item_os;
drop table if exists fotos_os;
drop table if exists pagamento;
drop table if exists item_peca_os;
drop table if exists ordem_servico;
drop table if exists estoque;
drop table if exists peca;
drop table if exists veiculo;
drop table if exists fornecedor;
drop table if exists mecanico;
drop table if exists colaborador;
drop table if exists cliente;
drop table if exists usuario;
drop table if exists perfil;

---------------------------------------------------------------------------------

create table if not exists perfil (
id_perfil int auto_increment primary key,
nome_perfil varchar(50) not null
);

insert into perfil (nome_perfil)
values
	('Administrador'),
    ('Atendente'),
    ('Gerente');
select * from perfil;

---------------------------------------------------------------------------------

create table if not exists usuario (
id_usuario int auto_increment primary key,
nome varchar(100) not null,
login varchar(50) unique not null,
senha varchar(255) not null,
id_perfil int not null,
constraint fk_usuario_perfil foreign key (id_perfil) references perfil(id_perfil)
);

insert into usuario (nome, login, senha, id_perfil)
values
	('Breno Honorato', 'breno.honorato', 'BrenoHB008', 1),
    ('Paulo Gustavo', 'paulo.gustavo', 'Paulo@2026', 2),
    ('Bruno Moreira', 'bruno.moreira', 'Bruno@2026', 2);
select * from usuario;

---------------------------------------------------------------------------------

create table if not exists cliente (
id_cliente int auto_increment primary key,
nome varchar(100) not null,
telefone varchar(20) unique not null,
email varchar(100) unique not null,
cpf_cnpj varchar(20) unique,
endereco varchar(100)
);

insert into cliente (nome, telefone, email, cpf_cnpj, endereco)
values
	('Bruno Silva', '9923-1323-2212', 'bruno@gmail.com', '01292931233', 'Rua Belterra, 291'),
    ('Paulo Mendes', '9923-12312-3948', 'paulo@gmail.com', '21301923123', 'Rua do Paulo, 311'),
    ('Carla Souza', '9921-4321-9812', 'carla@gmail.com', '32109812345', 'Av. Central, 120'),
    ('Marcos Lima', '9934-9812-1123', 'marcos@gmail.com', '45123098712', 'Rua das Flores, 45'),
    ('Fernanda Rocha', '9945-1298-3321', 'fernanda@gmail.com', '78912340098', 'Rua Nova, 78');
select * from cliente;

---------------------------------------------------------------------------------

create table if not exists mecanico (
id_mecanico int auto_increment primary key,
nome varchar(100) not null,
telefone varchar(20) unique not null,
especialidade varchar(50)
);

insert into mecanico (nome, telefone, especialidade)
values
	('Breno Honorato', '9912312323', 'Motor'),
    ('Joao Claudio', '9913123812', 'Suspensao'),
    ('Ricardo Alves', '9922145678', 'Eletrica'),
    ('Felipe Santos', '9933457890', 'Freios'),
    ('Diego Martins', '9944567123', 'Cambio');
select * from mecanico;

---------------------------------------------------------------------------------

create table if not exists fornecedor (
id_fornecedor int auto_increment primary key,
nome_razao varchar(100) not null,
telefone varchar(20) unique not null,
email varchar(100) unique not null
);

insert into fornecedor (nome_razao, telefone, email)
values
	('Joao Claudio Autopecas', '9913123812', 'joaoclaudio@gmail.com'),
    ('Peças Rapidas Ltda', '9911223344', 'contato@pecasrapidas.com'),
    ('Distribuidora Central', '9922334455', 'vendas@central.com'),
    ('AutoParts Brasil', '9933445566', 'comercial@autoparts.com'),
    ('Mega Pecas', '9944556677', 'contato@megapecas.com');
select * from fornecedor;

---------------------------------------------------------------------------------

create table if not exists veiculo (
id_veiculo int auto_increment primary key,
placa varchar(10) unique not null,
modelo varchar(50) not null,
marca varchar(50) not null,
ano int,
id_cliente int not null,
constraint fk_veiculo_cliente foreign key (id_cliente) references cliente(id_cliente)
);

insert into veiculo (placa, modelo, marca, ano, id_cliente)
values
	('HJQ9873', 'Corolla', 'Toyota', 2020, 1),
    ('PLK4521', 'Civic', 'Honda', 2019, 2),
    ('MNB7890', 'Onix', 'Chevrolet', 2021, 3),
    ('QWE3345', 'HB20', 'Hyundai', 2018, 4),
    ('ZXC9087', 'Gol', 'Volkswagen', 2022, 5);
select * from veiculo;

---------------------------------------------------------------------------------

create table if not exists estoque (
id_peca int auto_increment primary key,
codigo_barras varchar(50) unique not null,
descricao varchar(150) not null,
quantidade int default 0,
quantidade_minima int default 0,
valor_unitario decimal(10,2) not null,
localizacao varchar(50),
id_fornecedor int not null,
check (quantidade >= 0),
check (quantidade_minima >= 0),
constraint fk_estoque_fornecedor foreign key (id_fornecedor) references fornecedor(id_fornecedor)
);

insert into estoque (codigo_barras, descricao, quantidade, quantidade_minima, valor_unitario, localizacao, id_fornecedor)
values
	('COD001', 'Pneu', 76, 30, 0.50, 'Alameda Santos', 1),
    ('COD002', 'Pastilha de freio', 45, 20, 35.90, 'Corredor A2', 2),
    ('COD003', 'Filtro de oleo', 60, 25, 18.50, 'Corredor B1', 3),
    ('COD004', 'Amortecedor', 15, 5, 149.90, 'Corredor C3', 4),
    ('COD005', 'Correia dentada', 30, 10, 89.90, 'Corredor A4', 5);
select * from estoque;

---------------------------------------------------------------------------------

create table if not exists ordem_servico (
id_os int auto_increment primary key,
data_abertura datetime not null,
data_fechamento datetime,
status enum('Em aberto', 'Em andamento', 'Finalizada', 'Cancelada') default 'Em aberto',
observacoes text,
valor_total decimal(10,2) not null,
id_veiculo int not null,
id_mecanico int not null,
constraint fk_ordem_servico_veiculo foreign key (id_veiculo) references veiculo(id_veiculo),
constraint fk_ordem_servico_mecanico foreign key (id_mecanico) references mecanico(id_mecanico)
);

insert into ordem_servico (data_abertura, data_fechamento, status, observacoes, valor_total, id_veiculo, id_mecanico)
values
	('2026-07-18 09:00:00', '2026-07-20 17:00:00', 'Finalizada', 'Folga excessiva nos terminais de direcao e desgaste nas pastilhas de freio dianteiras.', 240.00, 1, 1),
    ('2026-07-22 10:30:00', null, 'Em andamento', 'Troca de oleo e filtro.', 120.00, 2, 3),
    ('2026-08-01 08:15:00', '2026-08-01 12:00:00', 'Finalizada', 'Revisao geral de suspensao.', 380.50, 3, 2),
    ('2026-08-05 14:00:00', null, 'Em aberto', 'Ruido no motor, aguardando diagnostico.', 0.00, 4, 5),
    ('2026-08-10 09:45:00', '2026-08-10 16:30:00', 'Finalizada', 'Troca da correia dentada.', 210.90, 5, 4);
select * from ordem_servico;

---------------------------------------------------------------------------------

create table if not exists item_os (
id_os int not null,
id_peca int not null,
quantidade int not null,
valor_unitario decimal(10,2) not null,
subtotal decimal(10,2) not null,
primary key (id_os, id_peca),
check (quantidade > 0),
constraint fk_item_os_ordem_servico foreign key (id_os) references ordem_servico(id_os),
constraint fk_item_os_estoque foreign key (id_peca) references estoque(id_peca)
);

insert into item_os (id_os, id_peca, quantidade, valor_unitario, subtotal)
values
	(1, 2, 2, 35.90, 71.80),
    (1, 1, 4, 0.50, 2.00),
    (2, 3, 1, 18.50, 18.50),
    (3, 4, 2, 149.90, 299.80),
    (5, 5, 1, 89.90, 89.90);
select * from item_os;

---------------------------------------------------------------------------------

create table if not exists conta_receber (
id_conta_receber int auto_increment primary key,
descricao varchar(150) not null,
valor decimal(10,2) not null,
data_vencimento date not null,
data_pagamento date,
status varchar(20) default 'Pendente',
forma_pagamento varchar(30),
id_os int not null,
constraint fk_conta_receber_ordem_servico foreign key (id_os) references ordem_servico(id_os)
);

insert into conta_receber (descricao, valor, data_vencimento, data_pagamento, status, forma_pagamento, id_os)
values
	('OS #1 - Servico de direcao e freios', 240.00, '2026-07-25', '2026-07-20', 'Pago', 'Credito', 1),
    ('OS #2 - Troca de oleo e filtro', 120.00, '2026-07-30', null, 'Pendente', null, 2),
    ('OS #3 - Revisao de suspensao', 380.50, '2026-08-08', '2026-08-01', 'Pago', 'Pix', 3),
    ('OS #5 - Troca de correia dentada', 210.90, '2026-08-15', '2026-08-10', 'Pago', 'Debito', 5);
select * from conta_receber;

---------------------------------------------------------------------------------

create table if not exists conta_pagar (
id_conta_pagar int auto_increment primary key,
descricao varchar(150) not null,
valor decimal(10,2) not null,
data_vencimento date not null,
data_pagamento date,
status varchar(20) default 'Pendente',
id_fornecedor int not null,
constraint fk_conta_pagar_fornecedor foreign key (id_fornecedor) references fornecedor(id_fornecedor)
);

insert into conta_pagar (descricao, valor, data_vencimento, data_pagamento, status, id_fornecedor)
values
	('Compra de pneus - lote 07/2026', 950.00, '2026-08-20', null, 'Pendente', 1),
    ('Compra de pastilhas de freio', 720.00, '2026-08-10', '2026-08-05', 'Pago', 2),
    ('Compra de filtros de oleo', 450.00, '2026-08-25', null, 'Pendente', 3),
    ('Compra de amortecedores', 1300.00, '2026-09-01', null, 'Pendente', 4),
    ('Compra de correias', 600.00, '2026-08-18', '2026-08-15', 'Pago', 5);
select * from conta_pagar;