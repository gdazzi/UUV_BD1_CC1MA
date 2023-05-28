-- DROP DATABASE IF EXISTS uvv;

-- Criação do usuário para administração do banco de dados.
DROP USER IF EXISTS dazzi;
CREATE USER dazzi WITH
    SUPERUSER
    CREATEDB 
    CREATEROLE 
    LOGIN 
    ENCRYPTED PASSWORD 'postg123';

-- Criação do banco de dados e definição do proprietário
-- Codificação UTF-8
CREATE DATABASE uvv
    WITH 
    OWNER = dazzi
    TEMPLATE = template0
    ENCODING = 'UTF8'
    LC_COLLATE = 'pt_BR.UTF-8'
    LC_CTYPE = 'pt_BR.UTF-8'
    ALLOW_CONNECTIONS = true;


-- Queda do schema lojas, se já existir.
DROP SCHEMA IF EXISTS lojas CASCADE;

-- Criação do schema lojas e autorização para o usuário criado anteriormente.
CREATE SCHEMA IF NOT EXISTS lojas AUTHORIZATION dazzi;
ALTER USER dazzi
SET SEARCH_PATH TO lojas, "\$user", public;

-- Definição das permissões para o usuário dazzi no schema lojas.
GRANT ALL ON SCHEMA lojas TO dazzi;
GRANT ALL ON ALL TABLES IN SCHEMA lojas TO dazzi;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA lojas TO dazzi;


CREATE TABLE lojas.produtos (
    produto_id NUMERIC(38) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    preco_unitario NUMERIC(10,2) NOT NULL CHECK (preco_unitario >= 0),
    detalhes BYTEA,
    imagem BYTEA,
    imagem_mime_type VARCHAR(512),
    imagem_arquivo VARCHAR(512),
    imagem_charset VARCHAR(512),
    imagem_ultima_atualizacao DATE,
    CONSTRAINT produtos_pk PRIMARY KEY (produto_id)
);

COMMENT ON COLUMN lojas.produtos.produto_id IS                  'ID do produto';
COMMENT ON COLUMN lojas.produtos.nome IS                        'Nome do produto';
COMMENT ON COLUMN lojas.produtos.preco_unitario IS              'Preço unitário do produto';
COMMENT ON COLUMN lojas.produtos.detalhes IS                    'Detalhes do produto (formato binário)';
COMMENT ON COLUMN lojas.produtos.imagem IS                      'Imagem do produto (formato binário)';
COMMENT ON COLUMN lojas.produtos.imagem_mime_type IS            'Tipo MIME da imagem';
COMMENT ON COLUMN lojas.produtos.imagem_arquivo IS              'Arquivo da imagem';
COMMENT ON COLUMN lojas.produtos.imagem_charset IS              'Charset da imagem';
COMMENT ON COLUMN lojas.produtos.imagem_ultima_atualizacao IS   'Data da última atualização da imagem';

-- Criação da tabela lojas no schema 'lojas'
CREATE TABLE lojas.lojas (
    loja_id NUMERIC(38) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    endereco_web VARCHAR(255),
    endereco_fisico VARCHAR(100),
    latitude NUMERIC,
    longitude NUMERIC,
    logo BYTEA,
    logo_mime_type VARCHAR(512),
    logo_arquivo VARCHAR(512),
    logo_charset VARCHAR(512),
    logo_ultima_atualizacao DATE NOT NULL,
    CONSTRAINT lojas_pk PRIMARY KEY (loja_id),
    CONSTRAINT lojas_endereco_check CHECK (endereco_web IS NOT NULL OR endereco_fisico IS NOT NULL)
);

-- Comentários das colunas da tabela lojas
COMMENT ON COLUMN lojas.lojas.loja_id IS                    'ID da loja';
COMMENT ON COLUMN lojas.lojas.nome IS                       'Nome da loja';
COMMENT ON COLUMN lojas.lojas.endereco_web IS               'Endereço web da loja';
COMMENT ON COLUMN lojas.lojas.endereco_fisico IS            'Endereço físico da loja';
COMMENT ON COLUMN lojas.lojas.latitude IS                   'Latitude da loja';
COMMENT ON COLUMN lojas.lojas.longitude IS                  'Longitude da loja';
COMMENT ON COLUMN lojas.lojas.logo IS                       'Logo da loja (formato binário)';
COMMENT ON COLUMN lojas.lojas.logo_mime_type IS             'Tipo MIME do logo';
COMMENT ON COLUMN lojas.lojas.logo_arquivo IS               'Arquivo do logo';
COMMENT ON COLUMN lojas.lojas.logo_charset IS               'Charset do logo';
COMMENT ON COLUMN lojas.lojas.logo_ultima_atualizacao IS    'Data da última atualização do logo';

-- Criação da tabela estoques no schema 'lojas'
CREATE TABLE lojas.estoques (
    estoque_id NUMERIC(38) NOT NULL,
    loja_id NUMERIC(38) NOT NULL,
    produto_id NUMERIC(38) NOT NULL,
    quantidade NUMERIC(38) NOT NULL CHECK (quantidade >= 0),
    CONSTRAINT estoques_pk PRIMARY KEY (estoque_id),
    CONSTRAINT estoques_lojas_fk FOREIGN KEY (loja_id) REFERENCES lojas.lojas (loja_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT estoques_produtos_fk FOREIGN KEY (produto_id) REFERENCES lojas.produtos (produto_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Comentários das colunas da tabela estoques
COMMENT ON COLUMN lojas.estoques.estoque_id IS  'ID do estoque';
COMMENT ON COLUMN lojas.estoques.loja_id IS     'ID da loja do estoque';
COMMENT ON COLUMN lojas.estoques.produto_id IS  'ID do produto do estoque';
COMMENT ON COLUMN lojas.estoques.quantidade IS  'Quantidade do produto no estoque';

-- Criação da tabela clientes no schema 'lojas'
CREATE TABLE lojas.clientes (
    cliente_id NUMERIC(38) NOT NULL,
    email VARCHAR(255) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    telefone1 VARCHAR(20) NOT NULL,
    telefone2 VARCHAR(20),
    telefone3 VARCHAR(20),
    CONSTRAINT clientes_pk PRIMARY KEY (cliente_id)
);

-- Comentários das colunas da tabela clientes
COMMENT ON COLUMN lojas.clientes.cliente_id IS  'ID do cliente';
COMMENT ON COLUMN lojas.clientes.email IS       'E-mail do cliente';
COMMENT ON COLUMN lojas.clientes.nome IS        'Nome do cliente';
COMMENT ON COLUMN lojas.clientes.telefone1 IS   'Telefone 1 do cliente';
COMMENT ON COLUMN lojas.clientes.telefone2 IS   'Telefone 2 do cliente';
COMMENT ON COLUMN lojas.clientes.telefone3 IS   'Telefone 3 do cliente';

-- Criação da tabela envios no schema 'lojas'
CREATE TABLE lojas.envios (
    envio_id VARCHAR NOT NULL,
    endereco_entrega VARCHAR(512) NOT NULL,
    loja_id NUMERIC(38) NOT NULL,
    cliente_id NUMERIC(38) NOT NULL,
    status VARCHAR(15) NOT NULL CHECK (status IN ('CRIADO', 'ENVIADO', 'TRANSITO', 'ENTREGUE')),
    CONSTRAINT envios_pk PRIMARY KEY (envio_id),
    CONSTRAINT envios_lojas_fk FOREIGN KEY (loja_id) REFERENCES lojas.lojas (loja_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT envios_clientes_fk FOREIGN KEY (cliente_id) REFERENCES lojas.clientes (cliente_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Comentários das colunas da tabela envios
COMMENT ON COLUMN lojas.envios.envio_id IS          'ID do envio';
COMMENT ON COLUMN lojas.envios.endereco_entrega IS  'Endereço de entrega';
COMMENT ON COLUMN lojas.envios.loja_id IS           'ID da loja do envio';
COMMENT ON COLUMN lojas.envios.cliente_id IS        'ID do cliente do envio';
COMMENT ON COLUMN lojas.envios.status IS            'Status do envio';

-- Criação da tabela pedidos no schema 'lojas'
CREATE TABLE lojas.pedidos (
    pedido_id NUMERIC(38) NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    cliente_id NUMERIC(38) NOT NULL,
    status VARCHAR(15) NOT NULL CHECK (status IN ('CANCELADO', 'COMPLETO', 'ABERTO', 'PAGO', 'REEMBOLSADO', 'ENVIADO')),
    loja_id NUMERIC(38) NOT NULL,
    CONSTRAINT pedidos_pk PRIMARY KEY (pedido_id),
    CONSTRAINT pedidos_clientes_fk FOREIGN KEY (cliente_id) REFERENCES lojas.clientes (cliente_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT pedidos_lojas_fk FOREIGN KEY (loja_id) REFERENCES lojas.lojas (loja_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Comentários das colunas da tabela pedidos
COMMENT ON COLUMN lojas.pedidos.pedido_id IS    'ID do pedido';
COMMENT ON COLUMN lojas.pedidos.data_hora IS    'Data e hora do pedido';
COMMENT ON COLUMN lojas.pedidos.cliente_id IS   'ID do cliente do pedido';
COMMENT ON COLUMN lojas.pedidos.status IS       'Status do pedido';
COMMENT ON COLUMN lojas.pedidos.loja_id IS      'ID da loja do pedido';

-- Criação da tabela pedidos_itens no schema 'lojas'
CREATE TABLE lojas.pedidos_itens (
    pedido_id NUMERIC(38) NOT NULL,
    produto_id NUMERIC(38) NOT NULL,
    numero_da_linha NUMERIC(38) NOT NULL,
    preco_unitario NUMERIC(10,2) NOT NULL CHECK (preco_unitario >= 0),
    quantidade NUMERIC(38) NOT NULL CHECK (quantidade >= 0),
    envio_id VARCHAR NOT NULL,
    CONSTRAINT pedidos_itens_pk PRIMARY KEY (pedido_id, produto_id),
    CONSTRAINT pedidos_itens_pedidos_fk FOREIGN KEY (pedido_id) REFERENCES lojas.pedidos (pedido_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT pedidos_itens_produtos_fk FOREIGN KEY (produto_id) REFERENCES lojas.produtos (produto_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT pedidos_itens_envios_fk FOREIGN KEY (envio_id) REFERENCES lojas.envios (envio_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Comentários das colunas da tabela pedidos_itens
COMMENT ON COLUMN lojas.pedidos_itens.pedido_id IS          'ID do pedido';
COMMENT ON COLUMN lojas.pedidos_itens.produto_id IS         'ID do produto';
COMMENT ON COLUMN lojas.pedidos_itens.numero_da_linha IS    'Número da linha do item no pedido';
COMMENT ON COLUMN lojas.pedidos_itens.quantidade IS         'Quantidade do produto no pedido';
COMMENT ON COLUMN lojas.pedidos_itens.envio_id IS           'ID do envio associado ao item do pedido';
