-- ============================================================
--   BASE DE DONNÉES : GESTION DE LA SCOLARITÉ - UIYA
--   Université Internationale de Yamoussoukro
--   Généré à partir du diagramme de classe du mémoire
-- ============================================================

-- Création et sélection de la base de données
CREATE DATABASE IF NOT EXISTS uiya_scolarite
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE uiya_scolarite;

-- ============================================================
-- 1. TABLE : permission
-- ============================================================
CREATE TABLE IF NOT EXISTS permission (
    id_permission   INT             NOT NULL AUTO_INCREMENT,
    libelle         VARCHAR(100)    NOT NULL,
    PRIMARY KEY (id_permission)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 2. TABLE : role
-- ============================================================
CREATE TABLE IF NOT EXISTS role (
    idrole      INT             NOT NULL AUTO_INCREMENT,
    libelle     VARCHAR(50)     NOT NULL,
    PRIMARY KEY (idrole)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 3. TABLE : role_permission  (relation Role <-> Permission)
-- ============================================================
CREATE TABLE IF NOT EXISTS role_permission (
    idrole          INT NOT NULL,
    id_permission   INT NOT NULL,
    PRIMARY KEY (idrole, id_permission),
    CONSTRAINT fk_rp_role       FOREIGN KEY (idrole)        REFERENCES role(idrole)             ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rp_permission FOREIGN KEY (id_permission) REFERENCES permission(id_permission) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 4. TABLE : utilisateur
-- ============================================================
CREATE TABLE IF NOT EXISTS utilisateur (
    id_utilisateur      INT             NOT NULL AUTO_INCREMENT,
    nom                 VARCHAR(100)    NOT NULL,
    prenoms             VARCHAR(150)    NOT NULL,
    email               VARCHAR(150)    NOT NULL UNIQUE,
    mot_de_passe        VARCHAR(255)    NOT NULL,
    type_utilisateur    ENUM('administrateur','responsable','enseignant','etudiant','parent') NOT NULL,
    genre               ENUM('M','F')   NOT NULL,
    telephone           VARCHAR(20)     NULL,
    adresse             VARCHAR(255)    NULL,
    idrole              INT             NOT NULL,
    PRIMARY KEY (id_utilisateur),
    CONSTRAINT fk_util_role FOREIGN KEY (idrole) REFERENCES role(idrole) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 5. TABLE : administrateur  (spécialisation de utilisateur)
-- ============================================================
CREATE TABLE IF NOT EXISTS administrateur (
    idAdmin         INT             NOT NULL AUTO_INCREMENT,
    id_utilisateur  INT             NOT NULL UNIQUE,
    mot_de_passe    VARCHAR(255)    NOT NULL,
    PRIMARY KEY (idAdmin),
    CONSTRAINT fk_admin_util FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_utilisateur) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 6. TABLE : filiere
-- ============================================================
CREATE TABLE IF NOT EXISTS filiere (
    id_filiere      INT             NOT NULL AUTO_INCREMENT,
    code_filiere    VARCHAR(20)     NOT NULL UNIQUE,
    nom_filiere     VARCHAR(150)    NOT NULL,
    niveau          VARCHAR(50)     NOT NULL,   -- Ex: Licence 1, Master 2 …
    resp_filiere    INT             NULL,        -- FK vers responsable (ajoutée après)
    PRIMARY KEY (id_filiere)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 7. TABLE : responsable  (spécialisation de utilisateur)
-- ============================================================
CREATE TABLE IF NOT EXISTS responsable (
    id_rep          INT             NOT NULL AUTO_INCREMENT,
    id_utilisateur  INT             NOT NULL UNIQUE,
    statut          VARCHAR(50)     NOT NULL DEFAULT 'actif',
    id_filiere      INT             NOT NULL,
    PRIMARY KEY (id_rep),
    CONSTRAINT fk_resp_util     FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_utilisateur) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_resp_filiere  FOREIGN KEY (id_filiere)     REFERENCES filiere(id_filiere)          ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Mise à jour du champ resp_filiere dans filiere après création de responsable
ALTER TABLE filiere
    ADD CONSTRAINT fk_filiere_resp FOREIGN KEY (resp_filiere) REFERENCES responsable(id_rep) ON DELETE SET NULL ON UPDATE CASCADE;


-- ============================================================
-- 8. TABLE : enseignant  (spécialisation de utilisateur)
-- ============================================================
CREATE TABLE IF NOT EXISTS enseignant (
    id_ens          INT             NOT NULL AUTO_INCREMENT,
    id_utilisateur  INT             NOT NULL UNIQUE,
    specialite      VARCHAR(150)    NOT NULL,
    PRIMARY KEY (id_ens),
    CONSTRAINT fk_ens_util FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_utilisateur) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 9. TABLE : classe
-- ============================================================
CREATE TABLE IF NOT EXISTS classe (
    id_cl       INT             NOT NULL AUTO_INCREMENT,
    nom_cl      VARCHAR(100)    NOT NULL,
    effectif    INT             NOT NULL DEFAULT 0,
    id_filiere  INT             NOT NULL,
    PRIMARY KEY (id_cl),
    CONSTRAINT fk_classe_filiere FOREIGN KEY (id_filiere) REFERENCES filiere(id_filiere) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 10. TABLE : etudiant  (spécialisation de utilisateur)
-- ============================================================
CREATE TABLE IF NOT EXISTS etudiant (
    id_ed           INT             NOT NULL AUTO_INCREMENT,
    id_utilisateur  INT             NOT NULL UNIQUE,
    date_naissance  DATE            NOT NULL,
    annee_scolaire  VARCHAR(20)     NOT NULL,   -- Ex: 2024-2025
    nationalite     VARCHAR(100)    NOT NULL,
    id_cl           INT             NOT NULL,
    PRIMARY KEY (id_ed),
    CONSTRAINT fk_etu_util   FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_utilisateur) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_etu_classe FOREIGN KEY (id_cl)          REFERENCES classe(id_cl)               ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 11. TABLE : parent  (spécialisation de utilisateur)
-- ============================================================
CREATE TABLE IF NOT EXISTS parent (
    idParent        INT             NOT NULL AUTO_INCREMENT,
    id_utilisateur  INT             NOT NULL UNIQUE,
    lien_parent     VARCHAR(50)     NOT NULL,  -- Ex: père, mère, tuteur …
    PRIMARY KEY (idParent),
    CONSTRAINT fk_parent_util FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_utilisateur) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 12. TABLE : parent_etudiant  (relation Parent <-> Etudiant)
-- ============================================================
CREATE TABLE IF NOT EXISTS parent_etudiant (
    idParent    INT NOT NULL,
    id_ed       INT NOT NULL,
    PRIMARY KEY (idParent, id_ed),
    CONSTRAINT fk_pe_parent   FOREIGN KEY (idParent) REFERENCES parent(idParent)   ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pe_etudiant FOREIGN KEY (id_ed)    REFERENCES etudiant(id_ed)    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 13. TABLE : cours
-- ============================================================
CREATE TABLE IF NOT EXISTS cours (
    idcours     INT             NOT NULL AUTO_INCREMENT,
    intitule    VARCHAR(200)    NOT NULL,
    matiere     VARCHAR(150)    NOT NULL,
    salle       VARCHAR(50)     NULL,
    id_filiere  INT             NOT NULL,
    id_ens      INT             NOT NULL,
    PRIMARY KEY (idcours),
    CONSTRAINT fk_cours_filiere FOREIGN KEY (id_filiere) REFERENCES filiere(id_filiere)   ON UPDATE CASCADE,
    CONSTRAINT fk_cours_ens     FOREIGN KEY (id_ens)     REFERENCES enseignant(id_ens)    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 14. TABLE : emploi_du_temps
-- ============================================================
CREATE TABLE IF NOT EXISTS emploi_du_temps (
    idEmploiDuTemps INT             NOT NULL AUTO_INCREMENT,
    jour            ENUM('Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi') NOT NULL,
    heur_debut      TIME            NOT NULL,
    heur_fin        TIME            NOT NULL,
    salle           VARCHAR(50)     NULL,
    id_filiere      INT             NOT NULL,
    id_cl           INT             NOT NULL,
    idcours         INT             NOT NULL,
    id_ens          INT             NOT NULL,
    PRIMARY KEY (idEmploiDuTemps),
    CONSTRAINT fk_edt_filiere FOREIGN KEY (id_filiere) REFERENCES filiere(id_filiere)       ON UPDATE CASCADE,
    CONSTRAINT fk_edt_classe  FOREIGN KEY (id_cl)      REFERENCES classe(id_cl)             ON UPDATE CASCADE,
    CONSTRAINT fk_edt_cours   FOREIGN KEY (idcours)    REFERENCES cours(idcours)            ON UPDATE CASCADE,
    CONSTRAINT fk_edt_ens     FOREIGN KEY (id_ens)     REFERENCES enseignant(id_ens)        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 15. TABLE : examen
-- ============================================================
CREATE TABLE IF NOT EXISTS examen (
    idexam          INT             NOT NULL AUTO_INCREMENT,
    datecompo       DATE            NOT NULL,
    libelle         VARCHAR(200)    NOT NULL,
    trimestre       TINYINT         NOT NULL,  -- 1, 2 ou 3
    annee_scolaire  VARCHAR(20)     NOT NULL,
    idcours         INT             NOT NULL,
    id_cl           INT             NOT NULL,
    PRIMARY KEY (idexam),
    CONSTRAINT fk_exam_cours  FOREIGN KEY (idcours) REFERENCES cours(idcours)  ON UPDATE CASCADE,
    CONSTRAINT fk_exam_classe FOREIGN KEY (id_cl)   REFERENCES classe(id_cl)   ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 16. TABLE : note
-- ============================================================
CREATE TABLE IF NOT EXISTS note (
    idnote      INT             NOT NULL AUTO_INCREMENT,
    valeur      DECIMAL(5,2)    NOT NULL,
    coefficient DECIMAL(4,2)    NOT NULL DEFAULT 1.00,
    trimestre   TINYINT         NOT NULL,
    appreciation VARCHAR(50)    NULL,      -- Ex: Très Bien, Bien, Assez Bien …
    moyenne     DECIMAL(5,2)    NULL,      -- calculée
    id_ed       INT             NOT NULL,
    idexam      INT             NOT NULL,
    idcours     INT             NOT NULL,
    PRIMARY KEY (idnote),
    CONSTRAINT fk_note_etu    FOREIGN KEY (id_ed)   REFERENCES etudiant(id_ed)  ON UPDATE CASCADE,
    CONSTRAINT fk_note_exam   FOREIGN KEY (idexam)  REFERENCES examen(idexam)   ON UPDATE CASCADE,
    CONSTRAINT fk_note_cours  FOREIGN KEY (idcours) REFERENCES cours(idcours)   ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- 17. TABLE : presence  (absences/présences)
-- ============================================================
CREATE TABLE IF NOT EXISTS presence (
    idpresence      INT             NOT NULL AUTO_INCREMENT,
    datepresence    DATE            NOT NULL,
    statut          ENUM('present','absent','retard') NOT NULL DEFAULT 'present',
    justifiee       TINYINT(1)      NOT NULL DEFAULT 0,  -- 0 = non justifiée
    id_ed           INT             NOT NULL,
    idEmploiDuTemps INT             NOT NULL,
    PRIMARY KEY (idpresence),
    CONSTRAINT fk_pres_etu FOREIGN KEY (id_ed)           REFERENCES etudiant(id_ed)              ON UPDATE CASCADE,
    CONSTRAINT fk_pres_edt FOREIGN KEY (idEmploiDuTemps) REFERENCES emploi_du_temps(idEmploiDuTemps) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- INDEXES SUPPLÉMENTAIRES pour les performances
-- ============================================================
CREATE INDEX idx_util_email         ON utilisateur(email);
CREATE INDEX idx_util_type          ON utilisateur(type_utilisateur);
CREATE INDEX idx_note_etu           ON note(id_ed);
CREATE INDEX idx_note_trimestre     ON note(trimestre);
CREATE INDEX idx_presence_date      ON presence(datepresence);
CREATE INDEX idx_presence_etu       ON presence(id_ed);
CREATE INDEX idx_edt_jour           ON emploi_du_temps(jour);
CREATE INDEX idx_edt_filiere        ON emploi_du_temps(id_filiere);
CREATE INDEX idx_examen_annee       ON examen(annee_scolaire);


-- ============================================================
-- DONNÉES DE TEST (jeu de données minimal)
-- ============================================================

-- Permissions
INSERT INTO permission (libelle) VALUES
    ('Gérer les utilisateurs'),
    ('Gérer les classes'),
    ('Gérer les filières'),
    ('Gérer les emplois du temps'),
    ('Gérer les cours'),
    ('Gérer les notes'),
    ('Gérer les absences'),
    ('Consulter les notes'),
    ('Consulter les emplois du temps'),
    ('Consulter les informations'),
    ('Consulter les statistiques');

-- Rôles
INSERT INTO role (libelle) VALUES
    ('Administrateur'),   -- idrole = 1
    ('Responsable'),      -- idrole = 2
    ('Enseignant'),       -- idrole = 3
    ('Etudiant'),         -- idrole = 4
    ('Parent');           -- idrole = 5

-- Association Rôle <-> Permission
INSERT INTO role_permission (idrole, id_permission) VALUES
    (1, 1),(1, 2),(1, 3),(1, 4),(1, 5),(1, 6),(1, 7),(1, 8),(1, 9),(1,10),(1,11),
    (2, 4),(2, 5),(2, 6),(2, 7),(2, 8),(2, 9),(2,10),(2,11),
    (3, 6),(3, 7),(3, 9),
    (4, 8),(4, 9),(4,10),
    (5, 8),(5, 9),(5,10);

-- Utilisateurs
INSERT INTO utilisateur (nom, prenoms, email, mot_de_passe, type_utilisateur, genre, telephone, adresse, idrole) VALUES
    ('DIALLO',   'Amadou',          'admin@uiya.ci',         SHA2('Admin@2024', 256), 'administrateur', 'M', '+225 07 00 00 01', 'Yamoussoukro', 1),
    ('KONE',     'Fatoumata',       'resp.info@uiya.ci',     SHA2('Resp@2024',  256), 'responsable',    'F', '+225 07 00 00 02', 'Yamoussoukro', 2),
    ('COULIBALY','Jean-Paul',       'jp.coulibaly@uiya.ci',  SHA2('Ens@2024',   256), 'enseignant',     'M', '+225 07 00 00 03', 'Yamoussoukro', 3),
    ('YAO',      'Adjoua Victoire', 'yao.adjoua@uiya.ci',    SHA2('Etu@2024',   256), 'etudiant',       'F', '+225 07 00 00 04', 'Yamoussoukro', 4),
    ('KANGA',    'Arsène',          'kanga.arsene@uiya.ci',  SHA2('Par@2024',   256), 'parent',         'M', '+225 07 00 00 05', 'Yamoussoukro', 5);

-- Administrateur
INSERT INTO administrateur (id_utilisateur, mot_de_passe) VALUES
    (1, SHA2('Admin@2024', 256));

-- Filière (sans responsable encore)
INSERT INTO filiere (code_filiere, nom_filiere, niveau, resp_filiere) VALUES
    ('GL', 'Génie Logiciel',          'Licence 3', NULL),
    ('GRH','Gestion des Ressources Humaines', 'Master 1', NULL);

-- Responsable
INSERT INTO responsable (id_utilisateur, statut, id_filiere) VALUES
    (2, 'actif', 1);

-- Mise à jour resp_filiere
UPDATE filiere SET resp_filiere = 1 WHERE id_filiere = 1;

-- Enseignant
INSERT INTO enseignant (id_utilisateur, specialite) VALUES
    (3, 'Développement Web & Base de Données');

-- Classe
INSERT INTO classe (nom_cl, effectif, id_filiere) VALUES
    ('GL3-A', 30, 1),
    ('GL3-B', 25, 1);

-- Étudiant
INSERT INTO etudiant (id_utilisateur, date_naissance, annee_scolaire, nationalite, id_cl) VALUES
    (4, '2001-05-15', '2020-2021', 'Ivoirienne', 1);

-- Parent
INSERT INTO parent (id_utilisateur, lien_parent) VALUES
    (5, 'Père');

-- Association Parent <-> Étudiant
INSERT INTO parent_etudiant (idParent, id_ed) VALUES
    (1, 1);

-- Cours
INSERT INTO cours (intitule, matiere, salle, id_filiere, id_ens) VALUES
    ('Conception de bases de données', 'Base de Données', 'Salle 101', 1, 1),
    ('Développement Web PHP',          'Programmation Web', 'Salle 102', 1, 1);

-- Emploi du temps
INSERT INTO emploi_du_temps (jour, heur_debut, heur_fin, salle, id_filiere, id_cl, idcours, id_ens) VALUES
    ('Lundi',    '08:00:00', '10:00:00', 'Salle 101', 1, 1, 1, 1),
    ('Mercredi', '10:00:00', '12:00:00', 'Salle 102', 1, 1, 2, 1);

-- Examen
INSERT INTO examen (datecompo, libelle, trimestre, annee_scolaire, idcours, id_cl) VALUES
    ('2021-01-15', 'Examen BD - Semestre 1',    1, '2020-2021', 1, 1),
    ('2021-01-20', 'Examen Web PHP - Semestre 1',1, '2020-2021', 2, 1);

-- Notes
INSERT INTO note (valeur, coefficient, trimestre, appreciation, moyenne, id_ed, idexam, idcours) VALUES
    (14.50, 3.00, 1, 'Assez Bien', 14.50, 1, 1, 1),
    (16.00, 2.00, 1, 'Bien',       16.00, 1, 2, 2);

-- Présences
INSERT INTO presence (datepresence, statut, justifiee, id_ed, idEmploiDuTemps) VALUES
    ('2021-01-04', 'present', 0, 1, 1),
    ('2021-01-06', 'absent',  0, 1, 2);


-- ============================================================
-- VUES UTILES
-- ============================================================

-- Vue : notes complètes d'un étudiant
CREATE OR REPLACE VIEW vue_notes_etudiant AS
SELECT
    u.nom,
    u.prenoms,
    c.intitule       AS cours,
    c.matiere,
    n.valeur         AS note,
    n.coefficient,
    n.trimestre,
    n.appreciation,
    n.moyenne,
    e.annee_scolaire
FROM note n
JOIN etudiant e  ON n.id_ed  = e.id_ed
JOIN utilisateur u ON e.id_utilisateur = u.id_utilisateur
JOIN cours c     ON n.idcours = c.idcours;

-- Vue : absences par étudiant
CREATE OR REPLACE VIEW vue_absences_etudiant AS
SELECT
    u.nom,
    u.prenoms,
    p.datepresence,
    p.statut,
    p.justifiee,
    edt.jour,
    edt.heur_debut,
    edt.heur_fin,
    co.matiere
FROM presence p
JOIN etudiant e    ON p.id_ed           = e.id_ed
JOIN utilisateur u ON e.id_utilisateur  = u.id_utilisateur
JOIN emploi_du_temps edt ON p.idEmploiDuTemps = edt.idEmploiDuTemps
JOIN cours co      ON edt.idcours       = co.idcours
WHERE p.statut = 'absent';

-- Vue : emploi du temps complet
CREATE OR REPLACE VIEW vue_emploi_du_temps AS
SELECT
    edt.jour,
    edt.heur_debut,
    edt.heur_fin,
    edt.salle,
    f.nom_filiere,
    cl.nom_cl,
    co.intitule   AS cours,
    co.matiere,
    u.nom         AS nom_enseignant,
    u.prenoms     AS prenom_enseignant
FROM emploi_du_temps edt
JOIN filiere f     ON edt.id_filiere = f.id_filiere
JOIN classe cl     ON edt.id_cl      = cl.id_cl
JOIN cours co      ON edt.idcours    = co.idcours
JOIN enseignant en ON edt.id_ens     = en.id_ens
JOIN utilisateur u ON en.id_utilisateur = u.id_utilisateur
ORDER BY FIELD(edt.jour,'Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi'), edt.heur_debut;


-- ============================================================
-- FIN DU SCRIPT
-- ============================================================
