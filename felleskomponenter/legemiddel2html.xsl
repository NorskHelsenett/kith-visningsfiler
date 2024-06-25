<?xml version="1.0" encoding="UTF-8"?>
	<!-- Endringslogg
	- 09.08.22: Semantisk HTML (endre <span class="strong"> til <b>)
	- 18.08.21: Lagt inn xsl:comment linjer for å unngå tomme div's
	- 04.06.21: Lagt til xsl:output for å definere at output formatet skal være html
	- 12.05.21: Fjern No-line-content fra tabellen for å unngå self-closing <div>'s
	- 08.04.21: Endre <span> til <div>, siden block-elementer (<ul>) inni inline-elementer (<span>) kan gi feil visning.
	- 04.12.15: Innføring av felles kodeverksfil. Småjusteringer på layout.
	-->
	<!-- Om
	- Inngår i Hdirs visningsfiler versjon 2.0
	- Laget i XMLSpy v2016 (http://www.altova.com) av Jan Sigurd Dragsjø (nhn.no)
	-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Filer som må importeres. Vanligvis gjøres dette i hovedfila som importerer denne komponentfila. Derfor er de kommentert ut. -->
	<xsl:import href="funksjoner.xsl"/>
	<xsl:import href="meldingshode2html.xsl"/>
	<xsl:import href="kodeverk.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Variabel for standard antall kolonner i tabellene-->
	<xsl:variable name="std-col" select="8"/>
	<xsl:variable name="std-td" select="100"/>
	
	<!-- Visning av innhold i Legemiddelinfo -->
	<xsl:template name="Legemiddelinfo">

		<xsl:variable name="Atc" select="boolean(../child::*[local-name()='Legemiddelinfo']//child::*[local-name()='Atc'])"/>
		<xsl:variable name="Form" select="boolean(../child::*[local-name()='Legemiddelinfo']//child::*[local-name()='Legemiddelform'])"/>
		<xsl:variable name="Styrke" select="boolean(../child::*[local-name()='Legemiddelinfo']//child::*[local-name()='Styrke'])"/>
		<xsl:variable name="BrukT" select="boolean(../child::*[local-name()='Legemiddelinfo']//child::*[local-name()='BruksomradeTekst'])"/>
		<xsl:variable name="Bruk" select="boolean(../child::*[local-name()='Legemiddelinfo']//child::*[local-name()='Bruk'])"/>
		<xsl:variable name="Dos" select="boolean(../child::*[local-name()='Legemiddelinfo']//child::*[local-name()='DosVeiledEnkel'])"/>
		<xsl:variable name="Skal" select="boolean(../child::*[local-name()='Legemiddelinfo']//child::*[local-name()='SkalIkkeTasSammenMedAnnetLegemiddel'])"/>
		<xsl:variable name="Start" select="boolean(../child::*[local-name()='Legemiddelinfo']//child::*[local-name()='DoseringStarttidspunkt'])"/>
		<xsl:variable name="Slutt" select="boolean(../child::*[local-name()='Legemiddelinfo']//child::*[local-name()='DoseringSluttidspunkt'])"/>
		<xsl:variable name="Status" select="boolean(../child::*[local-name()='Legemiddelinfo']//child::*[local-name()='StatusTilForskrivningen'])"/>
		<xsl:variable name="Forskr" select="boolean(../child::*[local-name()='Legemiddelinfo']//child::*[local-name()='Forskriver'])"/>
		<xsl:variable name="Merk" select="boolean(../child::*[local-name()='Legemiddelinfo']//child::*[local-name()='Merknad'])"/>
		<xsl:variable name="Multi" select="boolean(../child::*[local-name()='Legemiddelinfo']//child::*[local-name()='InngaarIMultidose'])"/>
		<xsl:variable name="Viktig" select="boolean(../child::*[local-name()='Legemiddelinfo']/@referanseViktigTilleggsinfo)"/>

		<xsl:variable name="stripedCss">
			<xsl:choose>
				<xsl:when test="boolean(position() mod 2)">striped</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- Visning av legemiddel-tabellen -->
		<xsl:if test="not(preceding-sibling::*[local-name()='Legemiddelinfo'])">
			<!-- Visning av legemiddel-tabellen header-overskrifter -->
			<div class="eh-row-8">
				<div class="eh-col-1 eh-label md">Navn og nr.</div>
				<xsl:if test="$Atc">
					<div class="eh-col-1 eh-label md">Atc</div>
				</xsl:if>
				<xsl:if test="$Form or $Styrke">
					<div class="eh-col-1 eh-label md">Form og styrke</div>
				</xsl:if>
				<xsl:if test="$BrukT or $Bruk or $Dos or $Skal">
					<div class="eh-col-1 eh-label md">Bruk og dosering</div>
				</xsl:if>
				<xsl:if test="$Start or $Slutt">
					<div class="eh-col-1 eh-label md">Start - slutt</div>
				</xsl:if>
				<xsl:if test="$Status">
					<div class="eh-col-1 eh-label md">Status</div>
				</xsl:if>
				<xsl:if test="$Forskr">
					<div class="eh-col-1 eh-label md">Forskriver</div>
				</xsl:if>
				<xsl:if test="$Multi">
					<div class="eh-col-1 eh-label md">Multidose</div>
				</xsl:if>
				<xsl:if test="$Merk">
					<div class="eh-col-1 eh-label md">Merknad</div>
				</xsl:if>
				<xsl:if test="$Viktig">
					<div class="eh-col-1 eh-label md">Viktig tilleggsinfo</div>
				</xsl:if>
			</div>
		</xsl:if>
		<div class="eh-row-8 {$stripedCss}">
			<div class="eh-col-1 eh-field {$stripedCss}">
				<div class="eh-label xs">Navn og nr.</div>
				<div class="eh-text">
					<div>
						<b>
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select=".//child::*[local-name()='Navn']"/>
							</xsl:call-template>
						</b>
					</div>
					<xsl:if test=".//child::*[local-name()='GeneriskNavn']">
						<div>
							<b>Generisk:</b>&#160;
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select=".//child::*[local-name()='GeneriskNavn']"/>
							</xsl:call-template>
						</div>
					</xsl:if>
					<xsl:if test=".//child::*[local-name()='Nr']">
						<div>
							<b>V.nr:</b>&#160;
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select=".//child::*[local-name()='Nr']"/>
							</xsl:call-template>
						</div>
					</xsl:if>
					<xsl:comment></xsl:comment>
				</div>
			</div>
			<xsl:if test="$Atc">
				<div class="eh-col-1 eh-field {$stripedCss}">
					<div class="eh-label xs">Atc</div>
					<div class="eh-text">
						<xsl:for-each select=".//child::*[local-name()='Atc']">
							<xsl:call-template name="k-dummy-V"/>&#160;
						</xsl:for-each>
						<xsl:comment></xsl:comment>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="$Form or $Styrke">
				<div class="eh-col-1 eh-field {$stripedCss}">
					<div class="eh-label xs">Form og styrke</div>
					<div class="eh-text">
						<xsl:for-each select=".//child::*[local-name()='Legemiddelform']">
							<xsl:call-template name="k-dummy"/>&#160;
						</xsl:for-each>
						<xsl:for-each select=".//child::*[local-name()='Styrke']">
							<xsl:value-of select="@V"/>&#160;<xsl:value-of select="@U"/>&#160;
						</xsl:for-each>
						<xsl:comment></xsl:comment>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="$BrukT or $Bruk or $Dos or $Skal">
				<div class="eh-col-1 eh-field {$stripedCss}">
					<div class="eh-label xs">Bruk og dosering</div>
					<div class="eh-text">
						<xsl:if test=".//child::*[local-name()='Bruk'] or .//child::*[local-name()='BruksomradeTekst']">
							<xsl:for-each select=".//child::*[local-name()='Bruk']">
								<xsl:call-template name="k-9101"/>&#160;
							</xsl:for-each>
							<xsl:for-each select=".//child::*[local-name()='BruksomradeTekst']">
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="."/>
								</xsl:call-template>&#160;
							</xsl:for-each>
						</xsl:if>
						<xsl:if test=".//child::*[local-name()='DosVeiledEnkel']">
							<xsl:for-each select=".//child::*[local-name()='DosVeiledEnkel']">
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="."/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:if>
						<xsl:if test=".//child::*[local-name()='SkalIkkeTasSammenMedAnnetLegemiddel']">
							<xsl:if test=".//child::*[local-name()='SkalIkkeTasSammenMedAnnetLegemiddel']='true'">
								<div>Skal&#160;ikke&#160;tas&#160;sammen med&#160;annet&#160;legemiddel</div>
							</xsl:if>
						</xsl:if>
						<xsl:comment></xsl:comment>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="$Start or $Slutt">
				<div class="eh-col-1 eh-field {$stripedCss}">
					<div class="eh-label xs">Start - slutt</div>
					<div class="eh-text">
						<xsl:if test=".//child::*[local-name()='DoseringStarttidspunkt']">
							<xsl:for-each select=".//child::*[local-name()='DoseringStarttidspunkt']">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="@V"/>
								</xsl:call-template>&#160;
							</xsl:for-each>
						</xsl:if>
						<xsl:if test=".//child::*[local-name()='DoseringSluttidspunkt']">
							<xsl:for-each select=".//child::*[local-name()='DoseringSluttidspunkt']">
								-&#160;<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="@V"/>
								</xsl:call-template>&#160;
							</xsl:for-each>
						</xsl:if>
						<xsl:comment></xsl:comment>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="$Status">
				<div class="eh-col-1 eh-field {$stripedCss}">
					<div class="eh-label xs">Status</div>
					<div class="eh-text">
						<xsl:for-each select=".//child::*[local-name()='StatusTilForskrivningen']">
							<xsl:call-template name="k-9104"/>&#160;
						</xsl:for-each>
						<xsl:comment></xsl:comment>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="$Forskr">
				<div class="eh-col-1 eh-field {$stripedCss}">
					<div class="eh-label xs">Forskriver</div>
					<div class="eh-text">
						<xsl:for-each select=".//child::*[local-name()='Forskriver']">
							<xsl:call-template name="HealthcareProfessional"/>
						</xsl:for-each>
						<xsl:comment></xsl:comment>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="$Multi">
				<div class="eh-col-1 eh-field {$stripedCss}">
					<div class="eh-label xs">Multidose</div>
					<div class="eh-text">
						<xsl:for-each select=".//child::*[local-name()='InngaarIMultidose']">
							<xsl:choose>
								<xsl:when test="@V='2'"><input type="checkbox" checked="checked" disabled="disabled"/></xsl:when>
								<xsl:otherwise><input type="checkbox" disabled="disabled"/></xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
						<xsl:comment></xsl:comment>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="$Merk">
				<div class="eh-col-1 eh-field {$stripedCss}">
					<div class="eh-label xs">Merknad</div>
					<div class="eh-text">
						<xsl:if test=".//child::*[local-name()='Merknad']">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select=".//child::*[local-name()='Merknad']"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:comment></xsl:comment>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="$Viktig">
				<div class="eh-col-1 eh-field {$stripedCss}">
					<div class="eh-label xs">Viktig tilleggsinfo</div>
					<div class="eh-text">
						<xsl:if test="@komponentID = //child::*[local-name()='tilleggsinfoEPJKomponent']//child::*[local-name()='linkTilKomponent']">
							Referert versjon
						</xsl:if>
						<xsl:if test="@referanseViktigTilleggsinfo">
							<xsl:variable name="var" select="./@referanseViktigTilleggsinfo"/>
							<div class="viktig">
								<xsl:for-each select="//child::*[local-name()='tilleggsinfoEPJKomponent'][@komponentID = $var]//child::*[local-name()='linktype']">
									<xsl:call-template name="k-9205"/>&#160;
								</xsl:for-each>
							</div>
							<xsl:if test="//child::*[local-name()='tilleggsinfoEPJKomponent'][@komponentID = $var]//child::*[local-name()='linkstyrke']">
								<div>
									<xsl:for-each select="//child::*[local-name()='tilleggsinfoEPJKomponent'][@komponentID = $var]//child::*[local-name()='linkstyrke']">
										<xsl:call-template name="k-9206"/>&#160;
									</xsl:for-each>
								</div>
							</xsl:if>
							<xsl:if test="//child::*[local-name()='tilleggsinfoEPJKomponent'][@komponentID = $var]//child::*[local-name()='merknad']">
								<div>
									<xsl:value-of select="//child::*[local-name()='tilleggsinfoEPJKomponent'][@komponentID = $var]//child::*[local-name()='merknad']"/>
								</div>
							</xsl:if>
						</xsl:if>
						<xsl:comment></xsl:comment>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>
	
	<!-- Visning av innhold i Legemidler administrert ved overføring -->
	<xsl:template name="LegemidlerAdministrertVedOverforing">
		<xsl:variable name="Atc" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='Atc'])"/>
		<xsl:variable name="Form" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='Legemiddelform'])"/>
		<xsl:variable name="Styrke" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='Styrke'])"/>
		<xsl:variable name="BrukT" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='BruksomradeTekst'])"/>
		<xsl:variable name="Bruk" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='Bruk'])"/>
		<xsl:variable name="Dos" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='DosVeiledEnkel'])"/>
		<xsl:variable name="Skal" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='SkalIkkeTasSammenMedAnnetLegemiddel'])"/>
		<xsl:variable name="Start" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='DoseringStarttidspunkt'])"/>
		<xsl:variable name="Slutt" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='DoseringSluttidspunkt'])"/>
		<xsl:variable name="Dose" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='AdmEnkeltdose'])"/>
		<xsl:variable name="Kvant" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='Kvantum'])"/>
		<xsl:variable name="Ant" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='AntEnkeltdoser'])"/>
		<xsl:variable name="AStart" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='AdmStart'])"/>
		<xsl:variable name="ASlutt" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='AdmSlutt'])"/>
		<xsl:variable name="AStatus" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='AdmStatus'])"/>
		<xsl:variable name="AAv" select="boolean(../child::*[local-name()='LegemidlerAdministrertVedOverforing']//child::*[local-name()='AdministrertAv'])"/>

		<!-- Visning av legemiddel-tabellen -->
		<xsl:if test="not(preceding-sibling::*[local-name()='LegemidlerAdministrertVedOverforing'])">
			<!-- Visning av legemiddel-tabellen header-overskrifter -->
			<div class="eh-row-8">
				<div class="eh-col-1 eh-label md">Navn og nr.</div>
				<xsl:if test="$Atc">
					<div class="eh-col-1 eh-label md">Atc</div>
				</xsl:if>
				<xsl:if test="$Form or $Styrke">
					<div class="eh-col-1 eh-label md">Form og styrke</div>
				</xsl:if>
				<xsl:if test="$BrukT or $Bruk or $Dos or $Skal">
					<div class="eh-col-1 eh-label md">Bruk og dosering</div>
				</xsl:if>
				<xsl:if test="$Start or $Slutt">
					<div class="eh-col-1 eh-label md">Start og slutt</div>
				</xsl:if>
				<xsl:if test="$Dose or $Kvant or $Ant">
					<div class="eh-col-1 eh-label md">Administrert mengde</div>
				</xsl:if>
				<xsl:if test="$AStart or $ASlutt or $AStatus">
					<div class="eh-col-1 eh-label md">Administrasjon</div>
				</xsl:if>
				<div class="eh-col-1 eh-label md">Administrert av</div>
			</div>
		</xsl:if>
		<xsl:for-each select="child::*">

			<xsl:variable name="stripedCss">
				<xsl:choose>
					<xsl:when test="boolean(position() mod 2)">striped</xsl:when>
					<xsl:otherwise></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<div class="eh-row-8 {$stripedCss}">
				<div class="eh-col-1 eh-field {$stripedCss}">
					<div class="eh-label xs">Navn og nr.</div>
					<div class="eh-text">
						<div>
							<b>
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select=".//child::*[local-name()='Navn']"/>
								</xsl:call-template>
							</b>
						</div>
						<xsl:if test=".//child::*[local-name()='GeneriskNavn']">
							<div>
								<b>Generisk:</b>&#160;
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select=".//child::*[local-name()='GeneriskNavn']"/>
								</xsl:call-template>
							</div>
						</xsl:if>
						<xsl:if test=".//child::*[local-name()='Nr']">
							<div>
								<b>Varenummer:</b>&#160;
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select=".//child::*[local-name()='Nr']"/>
								</xsl:call-template>
							</div>
						</xsl:if>
						<xsl:comment></xsl:comment>
					</div>
				</div>
				<xsl:if test="$Atc">
					<div class="eh-col-1 eh-field {$stripedCss}">
						<div class="eh-label xs">Atc</div>
						<div class="eh-text">
							<xsl:for-each select=".//child::*[local-name()='Atc']">
								<xsl:call-template name="k-dummy-V"/>&#160;
							</xsl:for-each>
							<xsl:comment></xsl:comment>
						</div>	
					</div>
				</xsl:if>
				<xsl:if test="$Form or $Styrke">
					<div class="eh-col-1 eh-field {$stripedCss}">
						<div class="eh-label xs">Form og styrke</div>
						<div class="eh-text">
							<xsl:for-each select=".//child::*[local-name()='Legemiddelform']">
								<xsl:call-template name="k-dummy"/>&#160;
							</xsl:for-each>
							<xsl:for-each select=".//child::*[local-name()='Styrke']">
								<xsl:value-of select="@V"/>&#160;<xsl:value-of select="@U"/>&#160;
							</xsl:for-each>
							<xsl:comment></xsl:comment>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="$BrukT or $Bruk or $Dos or $Skal">
					<div class="eh-col-1 eh-field {$stripedCss}">
						<div class="eh-label xs">Bruk og dosering</div>
						<div class="eh-text">
							<xsl:if test=".//child::*[local-name()='Bruk'] or .//child::*[local-name()='BruksomradeTekst']">
								<b>Bruk:</b>&#160;
								<xsl:for-each select=".//child::*[local-name()='Bruk']">
									<xsl:call-template name="k-9101"/>&#160;
								</xsl:for-each>
								<xsl:for-each select=".//child::*[local-name()='BruksomradeTekst']">
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="."/>
									</xsl:call-template>
								</xsl:for-each>
							</xsl:if>
							<xsl:if test=".//child::*[local-name()='DosVeiledEnkel']">
								<div>
									<b>Dosering:</b>&#160;
									<xsl:for-each select=".//child::*[local-name()='DosVeiledEnkel']">
										<xsl:call-template name="line-breaks">
											<xsl:with-param name="text" select="."/>
										</xsl:call-template>
									</xsl:for-each>
								</div>
							</xsl:if>
							<xsl:if test=".//child::*[local-name()='SkalIkkeTasSammenMedAnnetLegemiddel']">
								<xsl:if test=".//child::*[local-name()='SkalIkkeTasSammenMedAnnetLegemiddel']='true'">
									<div>Skal&#160;ikke&#160;tas&#160;sammen med&#160;annet&#160;legemiddel</div>
								</xsl:if>
							</xsl:if>
							<xsl:comment></xsl:comment>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="$Start or $Slutt">
					<div class="eh-col-1 eh-field {$stripedCss}">
						<div class="eh-label xs">Start og slutt</div>
						<div class="eh-text">
							<xsl:if test=".//child::*[local-name()='DoseringStarttidspunkt']">
								<b>Start:</b>&#160;
								<xsl:for-each select=".//child::*[local-name()='DoseringStarttidspunkt']">
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="@V"/>
									</xsl:call-template>&#160;
								</xsl:for-each>
							</xsl:if>
							<xsl:if test=".//child::*[local-name()='DoseringSluttidspunkt']">
								<div>
									<b>Slutt:</b>&#160;
									<xsl:for-each select=".//child::*[local-name()='DoseringSluttidspunkt']">
										<xsl:call-template name="skrivUtTS">
											<xsl:with-param name="oppgittTid" select="@V"/>
										</xsl:call-template>&#160;
									</xsl:for-each>
								</div>
							</xsl:if>
							<xsl:comment></xsl:comment>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="$Dose or $Kvant or $Ant">
					<div class="eh-col-1 eh-field {$stripedCss}">
						<div class="eh-label xs">Administrert mengde</div>
						<div class="eh-text">
							<xsl:if test=".//child::*[local-name()='Kvantum']">
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select=".//child::*[local-name()='Kvantum']"/>
								</xsl:call-template>
								&#160;x&#160;
							</xsl:if>
							<xsl:if test=".//child::*[local-name()='AntEnkeltdoser']">
								<xsl:value-of select=".//child::*[local-name()='AntEnkeltdoser']"/>
								&#160;x&#160;
							</xsl:if>
							<xsl:if test=".//child::*[local-name()='AdmEnkeltdose']">
								<xsl:value-of select=".//child::*[local-name()='AdmEnkeltdose']/@V"/>&#160;<xsl:value-of select=".//child::*[local-name()='AdmEnkeltdose']/@U"/>&#160;
							</xsl:if>
							<xsl:comment></xsl:comment>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="$AStart or $ASlutt or $AStatus">
					<div class="eh-col-1 eh-field {$stripedCss}">
						<div class="eh-label xs">Administrasjon</div>
						<div class="eh-text">
							<xsl:if test=".//child::*[local-name()='AdmStart']">
								<b>Start:</b>&#160;
								<xsl:for-each select=".//child::*[local-name()='AdmStart']">
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="@V"/>
									</xsl:call-template>&#160;
								</xsl:for-each>
							</xsl:if>
							<xsl:if test=".//child::*[local-name()='AdmSlutt']">
								<div>
									<b>Slutt:</b>&#160;
									<xsl:for-each select=".//child::*[local-name()='AdmSlutt']">
										<xsl:call-template name="skrivUtTS">
											<xsl:with-param name="oppgittTid" select="@V"/>
										</xsl:call-template>&#160;
									</xsl:for-each>
								</div>
							</xsl:if>
							<xsl:if test=".//child::*[local-name()='AdmStatus']">
								<div>
									<b>Status:</b>&#160;
									<xsl:for-each select=".//child::*[local-name()='AdmStatus']">
										<xsl:call-template name="k-9083"/>
									</xsl:for-each>
								</div>
							</xsl:if>
							<xsl:comment></xsl:comment>
						</div>
					</div>
				</xsl:if>
				<div class="eh-col-1 eh-field {$stripedCss}">
					<div class="eh-label xs">Administrert av</div>
					<div class="eh-text">
						<xsl:choose>
							<xsl:when test=".//child::*[local-name()='AdministrertAv']">
								<xsl:for-each select=".//child::*[local-name()='AdministrertAv']">
									<xsl:call-template name="HealthcareProfessional"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="local-name(.)='AdmAvHelsepersonell'">Helsepersonell</xsl:if>
								<xsl:if test="local-name(.)='Egenadministrering'">Pasient/pårørende</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:comment></xsl:comment>
					</div>
				</div>
			</div>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
