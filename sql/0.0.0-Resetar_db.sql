-- MySQL Workbench Forward Engineering
drop database ws;

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema ws
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema ws
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `ws` DEFAULT CHARACTER SET utf8 ;
USE `ws` ;

-- -----------------------------------------------------
-- Table `ws`.`dim_tempo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ws`.`dim_tempo` (
  `id_tempo` INT NOT NULL AUTO_INCREMENT,
  `data` DATE NOT NULL,
  PRIMARY KEY (`id_tempo`),
  UNIQUE INDEX `data_UNIQUE` (`data` ASC) VISIBLE,
  UNIQUE INDEX `id_tempo_UNIQUE` (`id_tempo` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ws`.`dim_movimentacao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ws`.`dim_movimentacao` (
  `id_movimentacao` INT NOT NULL AUTO_INCREMENT,
  `tipo_movimentacao` VARCHAR(70) NOT NULL,
  PRIMARY KEY (`id_movimentacao`),
  UNIQUE INDEX `tipo_movimentacao_UNIQUE` (`tipo_movimentacao` ASC) VISIBLE,
  UNIQUE INDEX `id_movimentacao_UNIQUE` (`id_movimentacao` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ws`.`dim_cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ws`.`dim_cliente` (
  `id_cliente` INT NOT NULL AUTO_INCREMENT,
  `nome_cliente` VARCHAR(150) NOT NULL,
  `cpf` VARCHAR(14) NULL,
  PRIMARY KEY (`id_cliente`),
  UNIQUE INDEX `id_cliente_UNIQUE` (`id_cliente` ASC) VISIBLE,
  UNIQUE INDEX `cpf_UNIQUE` (`cpf` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ws`.`dim_hora`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ws`.`dim_hora` (
  `id_hora` INT NOT NULL AUTO_INCREMENT,
  `hora` TIME NULL,
  PRIMARY KEY (`id_hora`),
  UNIQUE INDEX `id_hora_UNIQUE` (`id_hora` ASC) VISIBLE,
  UNIQUE INDEX `hora_UNIQUE` (`hora` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ws`.`fato_transacao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ws`.`fato_transacao` (
  `id_transacao` INT NOT NULL AUTO_INCREMENT,
  `id_tempo` INT NOT NULL,
  `id_hora` INT NULL,
  `id_cliente` INT NOT NULL,
  `id_movimentacao` INT NOT NULL,
  `id_recarga` INT NULL,
  `id_reentrada` INT NULL,
  `n_documento` VARCHAR(45) NULL,
  `valor` FLOAT NOT NULL,
  `coins` FLOAT NULL,
  `desconto` FLOAT NULL,
  `pontos` INT NULL,
  PRIMARY KEY (`id_transacao`),
  INDEX `id_tempo_idx` (`id_tempo` ASC) VISIBLE,
  INDEX `id_cliente_idx` (`id_cliente` ASC) VISIBLE,
  INDEX `id_movimentacao_idx` (`id_movimentacao` ASC) VISIBLE,
  UNIQUE INDEX `id_transacao_UNIQUE` (`id_transacao` ASC) VISIBLE,
  UNIQUE INDEX `id_recarga_UNIQUE` (`id_recarga` ASC) VISIBLE,
  UNIQUE INDEX `fato_transacaocol_UNIQUE` (`id_reentrada` ASC) VISIBLE,
  UNIQUE INDEX `n_documento_UNIQUE` (`n_documento` ASC) VISIBLE,
  CONSTRAINT `id_tempo`
    FOREIGN KEY (`id_tempo`)
    REFERENCES `ws`.`dim_tempo` (`id_tempo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `id_cliente`
    FOREIGN KEY (`id_cliente`)
    REFERENCES `ws`.`dim_cliente` (`id_cliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `id_movimentacao`
    FOREIGN KEY (`id_movimentacao`)
    REFERENCES `ws`.`dim_movimentacao` (`id_movimentacao`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `id_hora`
    FOREIGN KEY (`id_hora`)
    REFERENCES `ws`.`dim_hora` (`id_hora`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ws`.`dim_item`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ws`.`dim_item` (
  `id_item` INT NOT NULL AUTO_INCREMENT,
  `nome_item` VARCHAR(100) NOT NULL,
  `nome_abreviacao` VARCHAR(50) NULL,
  UNIQUE INDEX `nome_item_UNIQUE` (`nome_item` ASC) VISIBLE,
  PRIMARY KEY (`id_item`),
  UNIQUE INDEX `id_item_UNIQUE` (`id_item` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ws`.`dim_evento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ws`.`dim_evento` (
  `id_evento` INT NOT NULL AUTO_INCREMENT,
  `nome_evento` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id_evento`),
  UNIQUE INDEX `id_evento_UNIQUE` (`id_evento` ASC) VISIBLE,
  UNIQUE INDEX `nome_evento_UNIQUE` (`nome_evento` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ws`.`fato_promocao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ws`.`fato_promocao` (
  `id_promocao` INT NOT NULL AUTO_INCREMENT,
  `id_tempo` INT NOT NULL,
  `id_item` INT NOT NULL,
  `id_evento` INT NULL,
  `quantidade` INT NOT NULL,
  `valor_coin` INT NOT NULL,
  `valor_coin_original` INT NULL,
  PRIMARY KEY (`id_promocao`, `id_tempo`),
  UNIQUE INDEX `id_tempo_UNIQUE` (`id_tempo` ASC) VISIBLE,
  INDEX `id_item_idx` (`id_item` ASC) VISIBLE,
  INDEX `id_evento_idx` (`id_evento` ASC) VISIBLE,
  UNIQUE INDEX `id_promocao_UNIQUE` (`id_promocao` ASC) VISIBLE,
  CONSTRAINT `id_tempo_promocao`
    FOREIGN KEY (`id_tempo`)
    REFERENCES `ws`.`dim_tempo` (`id_tempo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `id_item`
    FOREIGN KEY (`id_item`)
    REFERENCES `ws`.`dim_item` (`id_item`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `id_evento`
    FOREIGN KEY (`id_evento`)
    REFERENCES `ws`.`dim_evento` (`id_evento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
