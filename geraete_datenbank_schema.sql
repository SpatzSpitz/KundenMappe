
-- ------------------------------
-- Geräte & Gerätetypen
-- ------------------------------

CREATE TABLE geraetetypen (
  id VARCHAR(50) PRIMARY KEY,
  bezeichnung VARCHAR(100) NOT NULL,
  hersteller VARCHAR(100),
  modell VARCHAR(100),
  beschreibung TEXT
);

CREATE TABLE geraete (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  geraetetyp_id VARCHAR(50),
  installationsort VARCHAR(255),
  status VARCHAR(50),
  projekt_id VARCHAR(50),
  rack_position_id VARCHAR(50),
  FOREIGN KEY (geraetetyp_id) REFERENCES geraetetypen(id)
);

-- ------------------------------
-- Schnittstellen
-- ------------------------------

CREATE TABLE schnittstellen (
  id VARCHAR(50) PRIMARY KEY,
  geraet_id VARCHAR(50) NOT NULL,
  name VARCHAR(100) NOT NULL,
  typ VARCHAR(50) NOT NULL,
  position VARCHAR(100),
  FOREIGN KEY (geraet_id) REFERENCES geraete(id)
);

CREATE TABLE schnittstellen_protokolle (
  schnittstelle_id VARCHAR(50),
  protokoll VARCHAR(50),
  PRIMARY KEY (schnittstelle_id, protokoll),
  FOREIGN KEY (schnittstelle_id) REFERENCES schnittstellen(id)
);

-- ------------------------------
-- Verbindungen (logisch)
-- ------------------------------

CREATE TABLE verbindungen (
  id VARCHAR(50) PRIMARY KEY,
  protokoll VARCHAR(50) NOT NULL,
  typ VARCHAR(50),
  quelle_geraet_id VARCHAR(50),
  quelle_schnittstelle_id VARCHAR(50),
  quelle_kanal INTEGER,
  ziel_geraet_id VARCHAR(50),
  ziel_schnittstelle_id VARCHAR(50),
  ziel_kanal INTEGER,
  beschreibung TEXT,
  FOREIGN KEY (quelle_geraet_id) REFERENCES geraete(id),
  FOREIGN KEY (ziel_geraet_id) REFERENCES geraete(id),
  FOREIGN KEY (quelle_schnittstelle_id) REFERENCES schnittstellen(id),
  FOREIGN KEY (ziel_schnittstelle_id) REFERENCES schnittstellen(id)
);

-- ------------------------------
-- Kabel & Anschlüsse
-- ------------------------------

CREATE TABLE kabel (
  id VARCHAR(50) PRIMARY KEY,
  bezeichnung VARCHAR(100),
  typ VARCHAR(50),
  laenge_m DECIMAL(5,2),
  farbe VARCHAR(50),
  verlegt_am DATE,
  status VARCHAR(50),
  beschreibung TEXT
);

CREATE TABLE kabel_anschluesse (
  kabel_id VARCHAR(50),
  geraet_id VARCHAR(50),
  schnittstelle_id VARCHAR(50),
  label VARCHAR(100),
  PRIMARY KEY (kabel_id, geraet_id, schnittstelle_id),
  FOREIGN KEY (kabel_id) REFERENCES kabel(id),
  FOREIGN KEY (geraet_id) REFERENCES geraete(id),
  FOREIGN KEY (schnittstelle_id) REFERENCES schnittstellen(id)
);

CREATE TABLE kabelstatus (
  status VARCHAR(50) PRIMARY KEY,
  beschreibung TEXT
);

-- ------------------------------
-- Kunden & Projekte
-- ------------------------------

CREATE TABLE kunden (
  id VARCHAR(50) PRIMARY KEY,
  firmenname VARCHAR(100) NOT NULL,
  anschrift TEXT,
  kontaktperson VARCHAR(100),
  telefon VARCHAR(50),
  email VARCHAR(100),
  notizen TEXT
);

CREATE TABLE projekte (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  kunde_id VARCHAR(50),
  startdatum DATE,
  enddatum DATE,
  status VARCHAR(50),
  beschreibung TEXT,
  FOREIGN KEY (kunde_id) REFERENCES kunden(id)
);

-- ------------------------------
-- Rack-Positionen
-- ------------------------------

CREATE TABLE rack_positionen (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100),
  ort TEXT
);

-- ------------------------------
-- Patchpanel
-- ------------------------------

CREATE TABLE patchpanel (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  position TEXT,
  beschreibung TEXT
);

CREATE TABLE patchports (
  id VARCHAR(50) PRIMARY KEY,
  patchpanel_id VARCHAR(50),
  portnummer INTEGER,
  name VARCHAR(50),
  verbunden_mit_schnittstelle_id VARCHAR(50),
  verbunden_mit_geraet_id VARCHAR(50),
  FOREIGN KEY (patchpanel_id) REFERENCES patchpanel(id),
  FOREIGN KEY (verbunden_mit_schnittstelle_id) REFERENCES schnittstellen(id),
  FOREIGN KEY (verbunden_mit_geraet_id) REFERENCES geraete(id)
);

-- ------------------------------
-- Software
-- ------------------------------

CREATE TABLE softwaretypen (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  beschreibung TEXT
);

CREATE TABLE softwares (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  version VARCHAR(50) NOT NULL,
  hersteller VARCHAR(100),
  beschreibung TEXT
);

CREATE TABLE geraete_softwares (
  geraet_id VARCHAR(50),
  software_id VARCHAR(50),
  softwaretyp_id VARCHAR(50),
  installiert_am DATE,
  kommentar TEXT,
  PRIMARY KEY (geraet_id, softwaretyp_id),
  FOREIGN KEY (geraet_id) REFERENCES geraete(id),
  FOREIGN KEY (software_id) REFERENCES softwares(id),
  FOREIGN KEY (softwaretyp_id) REFERENCES softwaretypen(id)
);

-- ------------------------------
-- Netzwerk
-- ------------------------------

CREATE TABLE vlans (
  id VARCHAR(50) PRIMARY KEY,
  vlan_id INTEGER NOT NULL,
  name VARCHAR(100),
  beschreibung TEXT
);

CREATE TABLE netzwerkadressen (
  id VARCHAR(50) PRIMARY KEY,
  geraet_id VARCHAR(50) NOT NULL,
  schnittstelle_id VARCHAR(50),
  ip_adresse VARCHAR(50) NOT NULL,
  subnetzmaske VARCHAR(50),
  gateway VARCHAR(50),
  vlan_id VARCHAR(50),
  dhcp BOOLEAN DEFAULT FALSE,
  notizen TEXT,
  FOREIGN KEY (geraet_id) REFERENCES geraete(id),
  FOREIGN KEY (schnittstelle_id) REFERENCES schnittstellen(id),
  FOREIGN KEY (vlan_id) REFERENCES vlans(id)
);

-- ------------------------------
-- Verbindung ↔ Kabel (physisch-logisch Verknüpfung)
-- ------------------------------

CREATE TABLE verbindung_kabel_links (
  verbindung_id VARCHAR(50),
  kabel_id VARCHAR(50),
  PRIMARY KEY (verbindung_id, kabel_id),
  FOREIGN KEY (verbindung_id) REFERENCES verbindungen(id),
  FOREIGN KEY (kabel_id) REFERENCES kabel(id)
);

-- Beispiel-View: Logische Verbindungen ohne physische Kabel
CREATE VIEW verbindungen_ohne_kabel AS
SELECT v.id, v.protokoll, v.beschreibung
FROM verbindungen v
LEFT JOIN verbindung_kabel_links vk ON v.id = vk.verbindung_id
WHERE vk.kabel_id IS NULL;
