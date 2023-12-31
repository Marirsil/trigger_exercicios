CREATE DATABASE exercicios_trigger;
USE exercicios_trigger;

CREATE TABLE Clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);

CREATE TABLE Auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mensagem TEXT NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    estoque INT NOT NULL
);

CREATE TABLE Pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT,
    quantidade INT NOT NULL,
    FOREIGN KEY (produto_id) REFERENCES Produtos(id)
);

DELIMITER //
CREATE TRIGGER insere_auditoria_cliente AFTER INSERT ON Clientes FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Novo cliente: ', NEW.nome, ' em ', NOW()));
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER tentativa_exclusao BEFORE DELETE ON Clientes FOR EACH ROW BEGIN
    INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Tentativa exclusão cliente: ', OLD.nome, ' em ', NOW()));
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER atualiza_nome_auditoria AFTER UPDATE ON Clientes FOR EACH ROW BEGIN
    IF NEW.nome IS NOT NULL AND NEW.nome != OLD.nome THEN
        INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Nome atualizado: ', OLD.nome, ' para ', NEW.nome, ' em ', NOW()));
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER impede_atualizacao_nome BEFORE UPDATE ON Clientes FOR EACH ROW BEGIN
    IF NEW.nome IS NULL OR NEW.nome = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nome não pode ser vazio ou NULL';
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER atualiza_estoque_pedido AFTER INSERT ON Pedidos FOR EACH ROW BEGIN
    UPDATE Produtos
    SET estoque = estoque - NEW.quantidade
    WHERE id = NEW.produto_id;

    IF (SELECT estoque FROM Produtos WHERE id = NEW.produto_id) < 5 THEN
        INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Estoque baixo produto: ', NEW.produto_id, ' em ', NOW()));
    END IF;
END;
//
DELIMITER ;
