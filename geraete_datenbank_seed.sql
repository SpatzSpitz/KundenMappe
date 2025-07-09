-- Beispiel-Datensätze für das Geräte-Datenbank-Schema

-- Gerätetypen
INSERT INTO geraetetypen (id, bezeichnung, hersteller, modell, beschreibung)
VALUES
  ('gt-router', 'Router', 'Cisco', 'RV340', 'VPN-Router'),
  ('gt-switch', 'Switch', 'Netgear', 'GS308', '8-Port Gigabit Switch'),
  ('gt-server', 'Server', 'Dell', 'PowerEdge T40', 'Kleiner Büroserver');

-- Geräte
INSERT INTO geraete (id, name, geraetetyp_id, installationsort, status,
                     projekt_id, rack_position_id)
VALUES
  ('g-router1', 'Router Büro', 'gt-router', 'Serverraum', 'aktiv', NULL, NULL),
  ('g-switch1', 'Switch Büro', 'gt-switch', 'Serverraum', 'aktiv', NULL, NULL),
  ('g-server1', 'Dateiserver', 'gt-server', 'Serverraum', 'aktiv', NULL, NULL);

-- Schnittstellen
INSERT INTO schnittstellen (id, geraet_id, name, typ, position)
VALUES
  ('if-router1-wan', 'g-router1', 'WAN', 'ethernet', 'port1'),
  ('if-router1-lan1', 'g-router1', 'LAN1', 'ethernet', 'port2'),
  ('if-switch1-1', 'g-switch1', 'Port1', 'ethernet', 'port1'),
  ('if-switch1-2', 'g-switch1', 'Port2', 'ethernet', 'port2'),
  ('if-server1-eth0', 'g-server1', 'eth0', 'ethernet', 'back');

-- Schnittstellen-Protokolle
INSERT INTO schnittstellen_protokolle (schnittstelle_id, protokoll)
VALUES
  ('if-router1-wan', 'pppoe'),
  ('if-router1-lan1', 'ethernet'),
  ('if-switch1-1', 'ethernet'),
  ('if-switch1-2', 'ethernet'),
  ('if-server1-eth0', 'ethernet');

-- Verbindungen (logisch)
INSERT INTO verbindungen (
  id, protokoll, typ,
  quelle_geraet_id, quelle_schnittstelle_id, quelle_kanal,
  ziel_geraet_id, ziel_schnittstelle_id, ziel_kanal, beschreibung)
VALUES
  ('v-router-switch', 'ethernet', 'lan',
   'g-router1', 'if-router1-lan1', NULL,
   'g-switch1', 'if-switch1-1', NULL,
   'Uplink Router zu Switch'),
  ('v-switch-server', 'ethernet', 'lan',
   'g-switch1', 'if-switch1-2', NULL,
   'g-server1', 'if-server1-eth0', NULL,
   'Serveranbindung');

-- Kabel & Anschlüsse
INSERT INTO kabel (id, bezeichnung, typ, laenge_m, farbe, verlegt_am,
                   status, beschreibung)
VALUES
  ('kabel1', 'Patchkabel 1', 'cat6', 1.5, 'blau', '2023-01-05', 'ok',
   'Verbindung Router zu Switch'),
  ('kabel2', 'Patchkabel 2', 'cat6', 1.5, 'gelb', '2023-01-05', 'ok',
   'Verbindung Switch zu Server');

INSERT INTO kabel_anschluesse (
  kabel_id, geraet_id, schnittstelle_id, label)
VALUES
  ('kabel1', 'g-router1', 'if-router1-lan1', 'Router LAN1'),
  ('kabel1', 'g-switch1', 'if-switch1-1', 'Switch Port1'),
  ('kabel2', 'g-switch1', 'if-switch1-2', 'Switch Port2'),
  ('kabel2', 'g-server1', 'if-server1-eth0', 'Server eth0');

INSERT INTO kabelstatus (status, beschreibung)
VALUES
  ('ok', 'Kabel funktioniert einwandfrei'),
  ('defekt', 'Kabel ist beschädigt');

-- Kunden & Projekte
INSERT INTO kunden (id, firmenname, anschrift, kontaktperson,
                    telefon, email, notizen)
VALUES
  ('kunde1', 'Musterfirma GmbH', 'Musterstraße 1, 12345 Musterstadt',
   'Max Mustermann', '+49 123 456789', 'info@musterfirma.de', NULL);

INSERT INTO projekte (id, name, kunde_id, startdatum, enddatum,
                      status, beschreibung)
VALUES
  ('projekt1', 'Büro-Netzwerk', 'kunde1', '2023-01-01', NULL,
   'in Bearbeitung', 'Aufbau des internen Netzwerks');

-- Rack-Positionen
INSERT INTO rack_positionen (id, name, ort)
VALUES
  ('rack1', 'Rack 1', 'Serverraum');

-- Patchpanel & Patchports
INSERT INTO patchpanel (id, name, position, beschreibung)
VALUES
  ('pp1', 'Patchpanel 1', 'Rack 1 oben', '24 Port Patchpanel');

INSERT INTO patchports (
  id, patchpanel_id, portnummer, name,
  verbunden_mit_schnittstelle_id, verbunden_mit_geraet_id)
VALUES
  ('pp1-p1', 'pp1', 1, 'Port1', 'if-switch1-1', 'g-switch1'),
  ('pp1-p2', 'pp1', 2, 'Port2', 'if-switch1-2', 'g-switch1');

-- Software & Gerät-Software-Zuordnung
INSERT INTO softwaretypen (id, name, beschreibung)
VALUES
  ('sw-os', 'Betriebssystem', 'Installiertes Betriebssystem'),
  ('sw-fw', 'Firmware', 'Gerätefirmware');

INSERT INTO softwares (id, name, version, hersteller, beschreibung)
VALUES
  ('sw-ubuntu', 'Ubuntu Server', '22.04', 'Canonical', 'LTS-Version'),
  ('sw-fw-router', 'Router Firmware', '1.0.0', 'Cisco', 'Standardfirmware');

INSERT INTO geraete_softwares (
  geraet_id, software_id, softwaretyp_id, installiert_am, kommentar)
VALUES
  ('g-server1', 'sw-ubuntu', 'sw-os', '2023-01-03', NULL),
  ('g-router1', 'sw-fw-router', 'sw-fw', '2023-01-02', NULL);

-- VLANs und Netzwerkadressen
INSERT INTO vlans (id, vlan_id, name, beschreibung)
VALUES
  ('vlan10', 10, 'Büro LAN', 'Internes Büronetz');

INSERT INTO netzwerkadressen (
  id, geraet_id, schnittstelle_id, ip_adresse,
  subnetzmaske, gateway, vlan_id, dhcp, notizen)
VALUES
  ('ip-router1', 'g-router1', 'if-router1-wan', '203.0.113.2',
   '255.255.255.0', '203.0.113.1', NULL, FALSE, 'WAN Adresse'),
  ('ip-router1-lan', 'g-router1', 'if-router1-lan1', '192.168.1.1',
   '255.255.255.0', NULL, 'vlan10', FALSE, NULL),
  ('ip-server1', 'g-server1', 'if-server1-eth0', '192.168.1.100',
   '255.255.255.0', '192.168.1.1', 'vlan10', FALSE, NULL);

-- Verbindung ↔ Kabel (physisch-logisch Verknüpfung)
INSERT INTO verbindung_kabel_links (verbindung_id, kabel_id)
VALUES
  ('v-router-switch', 'kabel1'),
  ('v-switch-server', 'kabel2');
