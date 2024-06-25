<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with XMLSpy v2013 rel2 sp2 (www.altova.com) by Jan Sigurd Dragsjø (www.helsedirektoratet.no) -->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	exclude-result-prefixes="mh">

	<!-- Visningsfil for forskrivninger og tilbakekallinger -->
	<!-- Endringslogg
	-	2022-08-09: v3.2.0: Semantisk HTML
	-	2021-06-04: v3.1.2: La til xsl:output for å definere at output formatet skal være html
	-	2017-03-27: v3.1.1: Ny parameter for "visningStil". Ny stil "Smooth".
	-	2016-10-25: v3.1.0: La til variabel for visningsversjonnr
	-	2014-02-12: La til visning av antall ifm legemiddelblanding
	-	2013-10-30: Oppdatert til også å håndtere versjon 2.5
	-	2011-04-28: Rettet bug med visning av antall handelsvarer
	-	2010-11-04: Oppdatert til også å håndtere versjon 2.4
	-	2010-01-06: Endret til versjon 2.31
		-	Fjernet import av visningsfil for hodemelding
		-	La inn kolonner for "Utleveringsgruppe" og "Info"
	-	2009-12-15: Første forslag til utprøving -->
	<!-- Bruk
	-	Visningsfilen må i sin egen katalog ha tilgang til en fil med navn "fil-liste.xml" som lister opp filnavn inne i "Fil"-tagger; f.eks. <Fil>m1-eksempelfil.xml</Fil>, eller <Fil>C:\Users\nn\temp\m1-eksempelfil.xml</Fil>
	-	Innholdet i Fil-taggene er filnavn for Resept-meldinger (M1) og eventuelle tilhørende Tilbakekalling-meldinger (M5).
	-	Visningsfila fungerer uavhengig av hvilken xml-fil den benyttes på.
	-	Struktur i "fil-liste.xml" er likegyldig rent bortsett fra taggene.	-->
	<!-- Visning
	-	Visningsfilen lister opp i tabellen "Forskrivninger" alle forskrivninger av legemiddeler og handelsvarer såfremt det ikke i fil-listen er en tilhørende tilbakekalling.
	-	Forskrivninger med tilhørende tilbakekalling listes opp i tabellen kalt "Tilbakekallinger". (Forskrivninger hvor MsgId matcher tilbakekallingsens ReseptId)
	-	Tabellene (både "Forskrivninger" og "Tilbakekallinger") inneholder kolonner som er merket: Bruk, NavnStyrkeForm, Mengde, Utl gr, Reit, Inof, Ref, DSSN
	-	CSS-klassene gir bl.a. forskjellig visning ved utskrift.	-->
	<!-- Svakheter
	-	Visningsfilen sjekker foreløpig ikke om det er samme pasient og samme rekvirent meldingene gjelder. Den henter aktør-info fra vilkårlig fil i fil-lista.	-->

	<xsl:import href="../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<xsl:param name="fil-union" select="document('fil-liste.xml')//Fil"/>
	<xsl:param name="meldings-union" select="document($fil-union)"/>

	
	<!-- Variabel for alle ReseptId-ene som tilbakekalles-->
	<xsl:variable name="tilbakekallte-Ider">
		<xsl:for-each select="$meldings-union/descendant::*[local-name()='Tilbakekalling']/child::*[local-name()='ReseptId']">
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:variable>

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'forskrivning - v3.2.0'"/>

	<xsl:template match="/">
		<html xmlns="http://www.w3.org/1999/xhtml">
			<head>
				<title>Forskrivninger og tilbakekallinger</title>
				<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
				<style type="text/css"><xsl:value-of select="document('../felleskomponenter/KITH-visning.css')" disable-output-escaping="yes" /></style>
			</head>
			<body>
				<xsl:for-each select="$meldings-union/mh:MsgHead">
					<xsl:if test="position()=1">
						<xsl:apply-templates select="mh:MsgInfo"/>
						<xsl:if test="count(descendant::*[local-name()='ReseptDokLegemiddel'])!=0 or count(descendant::*[local-name()='ReseptDokHandelsvare'])!=0">
							<xsl:call-template name="Forskrivninger"/>
						</xsl:if>
						<xsl:if test="count($meldings-union/descendant::*[local-name()='Tilbakekalling'])!=0 and count($meldings-union//mh:MsgInfo[contains($tilbakekallte-Ider, mh:MsgId)])!=0">
							<xsl:call-template name="Tilbakekallinger"/>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
				<xsl:call-template name="Info-blokk"/>
			</body>
		</html>
	</xsl:template>

	<!-- Visning av meldingshode -->
	<xsl:template match="mh:MsgInfo">
		<header class="No-line-doc">
			<table>
				<tbody>
					<tr>
						<td width="20%">
							<span class="strong">Pasient&#160;</span><br/>
							<xsl:for-each select="mh:Patient">
								<b><xsl:value-of select="mh:GivenName"/>&#160;<xsl:if test="mh:MiddleName"><xsl:value-of select="mh:MiddleName"/>&#160;</xsl:if><xsl:value-of select="mh:FamilyName"/></b>
								<xsl:if test="mh:Ident and mh:Ident/mh:TypeId/@V = 'FNR'">
									&#160;<xsl:apply-templates select="mh:Ident/mh:Id"/>
								</xsl:if>
							</xsl:for-each>
						</td>
						<td>
							<span class="strong">Rekvirent&#160;</span><br/>
							<xsl:for-each select="mh:Sender/mh:Organisation/mh:HealthcareProfessional">
								<b><xsl:value-of select="mh:GivenName"/>&#160;<xsl:value-of select="mh:FamilyName"/></b>
								<xsl:choose>
									<xsl:when test="descendant::*[local-name()='Resept']/child::*[local-name()='Spesialitet']">
										,&#160;<xsl:value-of select="descendant::*[local-name()='Resept']/child::*[local-name()='Spesialitet']/@DN"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:if test="mh:TypeHealthcareProfessional">
											,&#160;<xsl:value-of select="mh:TypeHealthcareProfessional/@DN"/>
										</xsl:if>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</td>
					</tr>
				</tbody>
			</table>
		</header>
	</xsl:template>

	<!-- Visning av forskrivninger -->
	<xsl:template name="Forskrivninger">
		<section class="{$stil}">
			<h3>Forskrivninger</h3>
			<table>
				<tbody>
					<tr>
						<th width="5%">Bruk</th>
						<th width="45%">NavnFormStyrke</th>
						<th width="15%">Mengde</th>
						<th width="5%">Utl gr</th>
						<th width="5%">Reit</th>
						<th width="5%">Info</th>
						<th width="10%">Refusjon</th>
						<th width="10%">DSSN</th>
					</tr>
					<xsl:choose>
						<xsl:when test="$meldings-union/descendant::*[local-name()='Tilbakekalling']">
							<xsl:for-each select="$meldings-union//mh:MsgInfo[not(contains($tilbakekallte-Ider, mh:MsgId))]/../descendant::*[local-name()='ReseptDokLegemiddel']">
								<xsl:call-template name="ReseptDokLegemiddel"/>
							</xsl:for-each>
							<xsl:for-each select="$meldings-union//mh:MsgInfo[not(contains($tilbakekallte-Ider, mh:MsgId))]/../descendant::*[local-name()='ReseptDokHandelsvare']">
								<xsl:call-template name="ReseptDokHandelsvare"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="$meldings-union/descendant::*[local-name()='ReseptDokLegemiddel']">
								<xsl:call-template name="ReseptDokLegemiddel"/>
							</xsl:for-each>
							<xsl:for-each select="$meldings-union/descendant::*[local-name()='ReseptDokHandelsvare']">
								<xsl:call-template name="ReseptDokHandelsvare"/>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</tbody>
			</table>
		</section>
	</xsl:template>

	<!-- Visning av tilbakekallinger -->
	<xsl:template name="Tilbakekallinger">
		<section class="{$stil}">
			<h3>Tilbakekallinger</h3>
			<table>
				<tbody>
					<tr>
						<th width="5%">Bruk</th>
						<th width="45%">NavnFormStyrke</th>
						<th width="15%">Mengde</th>
						<th width="5%">Utl gr</th>
						<th width="5%">Reit</th>
						<th width="5%">Info</th>
						<th width="10%">Refusjon</th>
						<th width="10%">DSSN</th>
					</tr>
					<xsl:for-each select="$meldings-union//mh:MsgInfo[contains($tilbakekallte-Ider, mh:MsgId)]/../descendant::*[local-name()='ReseptDokLegemiddel']">
						<xsl:call-template name="ReseptDokLegemiddel"/>
					</xsl:for-each>
					<xsl:for-each select="$meldings-union//mh:MsgInfo[contains($tilbakekallte-Ider, mh:MsgId)]/../descendant::*[local-name()='ReseptDokHandelsvare']">
						<xsl:call-template name="ReseptDokHandelsvare"/>
					</xsl:for-each>
				</tbody>
			</table>
		</section>
	</xsl:template>

	<!-- Visning av reseptdokument - legemiddel -->
	<xsl:template name="ReseptDokLegemiddel">
		<tr>
			<td>
				<xsl:for-each select="descendant::*[local-name()='Bruk']">
					<xsl:call-template name="k-9101"/>
				</xsl:for-each>
			</td>
			<td>
				<xsl:for-each select="descendant::*[local-name()='Legemiddelblanding']">
					<b><xsl:value-of select="child::*[local-name()='Navn']"/></b>&#160;:&#160;<xsl:value-of select="child::*[local-name()='TilbOppl']"/><br/>				
				</xsl:for-each>
				<xsl:for-each select="descendant::*[local-name()='NavnFormStyrke']">
					<xsl:if test="position() != 1"><br/></xsl:if>
					<xsl:value-of select="."/>
					<xsl:if test="../child::*[local-name()='Atc']">&#160;<b>ATC:</b>&#160;<xsl:value-of select="../child::*[local-name()='Atc']/@DN"/></xsl:if>
				</xsl:for-each>
			</td>
			<td valign="bottom">
				<xsl:choose>
					<xsl:when test="descendant::*[local-name()='Legemiddelblanding']">
						<xsl:for-each select="child::*[local-name()='Antall']">
							<xsl:if test=".!='1'">
								<xsl:value-of select="."/>&#160;x
							</xsl:if>
						</xsl:for-each>
						<xsl:for-each select="child::*[local-name()='Mengde']">
							<b><xsl:value-of select="@V"/>&#160;<xsl:value-of select="@U"/></b><br/>
						</xsl:for-each>
						<xsl:for-each select="descendant::*[local-name()='Legemiddelblanding']/descendant::*[local-name()='Mengde']">
							<xsl:value-of select="@V"/>&#160;<xsl:value-of select="@U"/><br/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="descendant::*[local-name()='PakningsinfoResept']">
								<xsl:for-each select="child::*[local-name()='Antall']">
									<xsl:if test=".!='1'">
										<xsl:value-of select="."/>&#160;pk&#160;á
									</xsl:if>
								</xsl:for-each>
								<xsl:for-each select="descendant::*[local-name()='PakningsinfoResept']">
									<xsl:if test="position()!=1">/</xsl:if>
									<xsl:value-of select="child::*[local-name()='Pakningsstr']"/>&#160;<xsl:value-of select="child::*[local-name()='EnhetPakning']/@V"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="child::*[local-name()='Antall']">
									<xsl:if test=".!='1'">
										<xsl:value-of select="."/>&#160;x
									</xsl:if>
								</xsl:for-each>
								<xsl:for-each select="child::*[local-name()='Mengde']">
									<xsl:value-of select="@V"/>&#160;<xsl:value-of select="@U"/>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:for-each select="descendant::*[local-name()='Reseptgruppe']">
					<xsl:value-of select="@V"/>
				</xsl:for-each>
			</td>
			<td>
				<xsl:for-each select="child::*[local-name()='Reiterasjon']">
					<xsl:value-of select="."/>
				</xsl:for-each>
			</td>
			<td>
				<xsl:if test="../child::*[local-name()='RekvLegensNavn'] = 'true'">A</xsl:if>
				<xsl:if test="../child::*[local-name()='RefNr']">R</xsl:if>
				<xsl:if test="../child::*[local-name()='Vergeinnsynsreservasjon'] = 'true'">V</xsl:if>
				<xsl:if test="../child::*[local-name()='EkspAnm']">E</xsl:if>
				<xsl:if test="child::*[local-name()='BytteresRekvirent']/@V = '1'">B</xsl:if>
				<xsl:if test="../child::*[local-name()='Instituert']">I</xsl:if>
			</td>
			<td>
				<xsl:if test="child::*[local-name()='RefHjemmel']/@V != '200'">
					<xsl:for-each select="child::*[local-name()='RefHjemmel']">
						<xsl:value-of select="@DN"/>&#160;
					</xsl:for-each>
				</xsl:if>
				<xsl:for-each select="child::*[local-name()='RefKode']">
					<xsl:value-of select="@V"/>
				</xsl:for-each>
			</td>
			<td>
				<xsl:for-each select="descendant::*[local-name()='DosVeiledEnkel']">
					<xsl:value-of select="."/>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>	
	
	<!-- Visning av reseptdokument - handelsvarer -->
	<xsl:template name="ReseptDokHandelsvare">
		<tr>
			<td>
				<xsl:for-each select="child::*[local-name()='Naringsmiddel']">N</xsl:for-each>
			</td>
			<td>
				<xsl:for-each select="child::*[local-name()='ProdGruppe']">
					<xsl:value-of select="@DN"/>,&#160;<xsl:value-of select="@V"/>
				</xsl:for-each>
				<xsl:if test="child::*[local-name()='ProdGruppe'] and count(descendant::*[local-name()='Navn'])!=0">,&#160;</xsl:if>
				<xsl:for-each select="descendant::*[local-name()='Navn' and not(parent::*[local-name()='BestanddelMatr'])]">
					<xsl:value-of select="."/>&#160;
					<xsl:for-each select="descendant::*[local-name()='BestanddelMatr']">,&#160;
						<span class="strong">Bestanddel:&#160;</span><xsl:value-of select="child::*[local-name()='Navn']"/>&#160;
					</xsl:for-each>
				</xsl:for-each>
				<xsl:for-each select="descendant::*[local-name()='StyrkeFormStoff']">
					<xsl:for-each select="child::*[local-name()='Styrke']">
						<xsl:value-of select="."/>&#160;
					</xsl:for-each>
					<xsl:for-each select="child::*[local-name()='Form']">
						<xsl:value-of select="."/>&#160;
					</xsl:for-each>
					<xsl:for-each select="child::*[local-name()='Stoff']">
						<xsl:value-of select="."/>&#160;
					</xsl:for-each>
				</xsl:for-each>
			</td>
			<td>
				<xsl:for-each select="child::*[local-name()='Antall']">
					<xsl:value-of select="."/>&#160;stk
				</xsl:for-each>
				<xsl:for-each select="descendant::*[local-name()='ProduktInfoVare']">
					<xsl:value-of select="child::*[local-name()='AntPerPakning']"/>&#160;<xsl:value-of select="child::*[local-name()='EnhetStorrelse']"/>
					<xsl:for-each select="child::*[local-name()='Volum']">
						&#160;á&#160;<xsl:value-of select="."/>
					</xsl:for-each>
				</xsl:for-each>
			</td>
			<td>
				<!-- Ingen utleveringsgruppe for handelsvarer -->
			</td>
			<td>
				<!-- Ingen reiterasjon for handelsvarer -->
			</td>
			<td>
				<xsl:if test="../child::*[local-name()='RekvLegensNavn'] = 'true'">A</xsl:if>
				<xsl:if test="../child::*[local-name()='RefNr']">R</xsl:if>
				<xsl:if test="../child::*[local-name()='Vergeinnsynsreservasjon'] = 'true'">V</xsl:if>
				<xsl:if test="../child::*[local-name()='EkspAnm']">E</xsl:if>
				<xsl:if test="child::*[local-name()='BytteresRekvirent']/@V = '1'">B</xsl:if>
				<xsl:if test="../child::*[local-name()='Instituert']">I</xsl:if>
			</td>
			<td>
				<xsl:for-each select="child::*[local-name()='RefHjemmel']">
					<xsl:value-of select="@DN"/>&#160;
				</xsl:for-each>
			</td>
			<td>
				<xsl:for-each select="child::*[local-name()='Bruksveiledning']">
					<xsl:value-of select="."/>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>
	
	<!-- Info-blokk -->
	<xsl:template name="Info-blokk">
		<div class="No-line-doc">
			<table>
				<tbody>
					<tr>
						<td width="20%">A = Forskrivning i legenes navn</td>
						<td width="20%">R = Referansenummer</td>
						<td>V = Vergeinnsynsreservasjon</td>
					</tr>
					<tr>
						<td width="20%">E = Ekspederingsanmodning</td>
						<td width="20%">B = Byttereservasjon</td>
						<td>I = Instituert av</td>
					</tr>
				</tbody>
			</table>
		</div>
	</xsl:template>
		
	<!-- Kodeverk -->
	<xsl:template name="k-9101">
		<xsl:choose>
			<xsl:when test="@V='1'">F</xsl:when>
			<xsl:when test="@V='2'">K</xsl:when>
			<xsl:when test="@V='3'">B</xsl:when>
			<xsl:when test="@V='4'">V</xsl:when>
			<xsl:when test="@V='5'">N</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
