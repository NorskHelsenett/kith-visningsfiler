<?xml version="1.0" encoding="UTF-8"?>
<!--
	Felleskomponenter basert på CSS styling i "ehelse-visning.css"
	og versjonuavhengige xsl-filer (dvs. bruker ikke namespace prefiks).
-->
<!-- Endringslogg
	- 01.02.24: Epikrise 1.2: Bruk kodeverk 9101 i status for medisinering
	            Fiks for visning av innhold med xhtml-feil
	- 17.10.23: Tydeliggjøring av Behov for Tolk - Språk
	- 09.08.22: Semantisk HTML (endre <span class="strong"> til <b>)
	- 31.08.21: Endre størrelse felter under Legemiddelopplysninger. Kodeverk 8244 i rød tekst.
	- 18.08.21: Lagt inn xsl:comment linjer for å unngå tomme div's
	- 04.06.21: Lagt til xsl:output for å definere at output formatet skal være html
	- 31.05.21: Tillate MimeType (vedlegg) med store bokstaver
	- 08.04.21: Endre <span> til <div>, siden block-elementer (<ul>) inni inline-elementer (<span>) kan gi feil visning.
-->

<xsl:stylesheet version="1.0"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1"
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24"
	xmlns:base="http://www.kith.no/xmlstds/base64container"
	exclude-result-prefixes="xsl xhtml fk1 mh base"
	>

	<!-- Disse må være importert i hovedfila: -->
	<xsl:import href="../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../felleskomponenter/meldingshode2html.xsl"/>


	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Disse templater må være definert (evt. tom) i hovefila fordi de kan kalles herfa:
		"Diagnosis-DiagComment-CodedDescr-CodedComment"
	-->

	<xsl:template name="eh-Observation">
		<!-- Henvisning v2.0: 				MsgHead/Document/RefDoc/Content/Henvisning/InfItem/Observation  -->
		<!-- Henvisning v1.0, v1.1 :		Message/ServReq/Patient/InfItem/Observation -->
		<!-- Epikrise v1.0, v1.1, v1.2 : 	Message/ServRprt/Event/InfItem/Observation -->
		<!-- Svarrapport m.fl? -->
		<div class="eh-row-5">

			<xsl:variable name="cssClass">
				<xsl:choose>
					<xsl:when test="../child::*[local-name()='StartDateTime'] | ../child::*[local-name()='EndDateTime'] | ../child::*[local-name()='OrgDate'] | child::*[local-name()='CodedDescr']"></xsl:when>
					<xsl:otherwise>eh-last-child</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="../child::*[local-name()='StartDateTime'] | ../child::*[local-name()='EndDateTime'] | ../child::*[local-name()='OrgDate']">
				<div class="eh-col-1">
					<div class="eh-field">
						<xsl:if test="../child::*[local-name()='StartDateTime']">
							<xsl:choose>
								<xsl:when test="../child::*[local-name()='StartDateTime']/@V"> <!-- kith:TS -->
									Start:&#160;<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="../child::*[local-name()='StartDateTime']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise> <!-- dateTime, date, etc. -->
									Start:&#160;<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="../child::*[local-name()='StartDateTime']"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="../child::*[local-name()='EndDateTime']">
							<xsl:if test="../child::*[local-name()='StartDateTime']">
								<xsl:value-of select="', '"/>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="../child::*[local-name()='EndDateTime']/@V"> <!-- kith:TS -->
									Slutt:&#160;<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="../child::*[local-name()='EndDateTime']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise> <!-- dateTime, date, etc. -->
									Slutt:&#160;<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="../child::*[local-name()='EndDateTime']"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="../child::*[local-name()='OrgDate']">
							<xsl:if test="../child::*[local-name()='StartDateTime'] or ../child::*[local-name()='EndDateTime']">
								<xsl:value-of select="', '"/>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="../child::*[local-name()='OrgDate']/@V"> <!-- kith:TS -->
									Opprinnelse:&#160;<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="../child::*[local-name()='OrgDate']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise> <!-- dateTime, date, etc. -->
									Opprinnelse:&#160;<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="../child::*[local-name()='OrgDate']"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</div>
				</div>
			</xsl:if>

			<!-- Epikrise only -->
			<xsl:for-each select="child::*[local-name()=&quot;CodedDescr&quot;]">
				<xsl:call-template name="Diagnosis-DiagComment-CodedDescr-CodedComment"/>
			</xsl:for-each>
    		<xsl:if test="child::*[local-name()='Description'] or child::*[local-name()='Comment']">
				<div class="eh-col-1 eh-last-child" >
					<xsl:if test="../child::*[local-name()='Type']/@DN">
						<div class="eh-label">
							<xsl:value-of select="../child::*[local-name()='Type']/@DN"/>
						</div>
					</xsl:if>
					<div class="eh-field" xmlns="http://www.w3.org/1999/xhtml">
						<xsl:if test="child::*[local-name()='Description']"> <!--  type="kith:ST" eller "anyType" -->
							<xsl:choose>
								<xsl:when test="child::*[local-name()='Description'][count(child::*)>0]">
									<xsl:copy-of select="child::*[local-name()='Description']/node()"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="child::*[local-name()='Description']"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="child::*[local-name()='Description'] and child::*[local-name()='Comment']">
							<br/>
						</xsl:if>
						<xsl:if test="child::*[local-name()='Comment']"> <!-- type="kith:ST" -->
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='Comment']"/>
							</xsl:call-template>
						</xsl:if>
					</div>
				</div>
			</xsl:if>

		</div>
	</xsl:template>

	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:template name="eh-Medication"> <!-- Henvisning/InfItem/Medication -->
		<xsl:param name="striped" />
		<!-- Henvisning v1.0, v1.1, v2.0 -->
		<!-- Epikrise v1.0, v1.1, v1.2. Skjema epikrise har flere elementer enn henvisning, men de brukes ikke i denne templaten. -->
		<!-- Merk: rad-element ikke inkludert her. -->


		<div class="eh-col-2-xs eh-field {$striped}">
			<div class="eh-text">
				<xsl:for-each select="child::*[local-name()='DrugId']">
					<xsl:call-template name="k-dummy"/>
				</xsl:for-each>
				<xsl:comment></xsl:comment>
			</div>
		</div>

		<div class="eh-col-1-xs eh-field {$striped}">
			<div class="eh-text">
				<xsl:choose>
					<xsl:when test="namespace-uri() = 'http://ehelse.no/xmlstds/henvisning/2017-11-30' or namespace-uri() = 'http://www.kith.no/xmlstds/epikrise/2012-02-15'"><!-- Henvisning v2.0--><!--Epikrise v1.2-->
						<xsl:for-each select="child::*[local-name()='Status']">
							<xsl:call-template name="k-9101"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise><!-- Henvisning v1.0 og v1.1 -->
						<xsl:for-each select="child::*[local-name()='Status']">
							<xsl:call-template name="k-7307"/>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:comment></xsl:comment>
			</div>
		</div>

		<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='UnitDose'] or //child::*[local-name()='Medication']/child::*[local-name()='QuantitySupplied']">
			<div class="eh-col-1-xs eh-field {$striped}">
				<div class="eh-text">
					<xsl:if test="child::*[local-name()='UnitDose']">
						<xsl:value-of select="child::*[local-name()='UnitDose']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='UnitDose']/@U "/>
						<xsl:if test="child::*[local-name()='QuantitySupplied']">&#160;x&#160;</xsl:if>
					</xsl:if>
					<xsl:if test="child::*[local-name()='QuantitySupplied']">
						<xsl:value-of select="child::*[local-name()='QuantitySupplied']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='QuantitySupplied']/@U"/>
					</xsl:if>
					<xsl:comment></xsl:comment>
				</div>
			</div>
		</xsl:if>

		<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='DosageText'] or //child::*[local-name()='Medication']/child::*[local-name()='IntendedDuration']">
			<div class="eh-col-1 eh-field {$striped}">
				<div class="eh-text">
					<xsl:if test="child::*[local-name()='DosageText']">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='DosageText']"/>
						</xsl:call-template>
					</xsl:if>&#160;
					<xsl:if test="child::*[local-name()='IntendedDuration']">&#160;/&#160;<xsl:value-of select="child::*[local-name()='IntendedDuration']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='IntendedDuration']/@U"/>
					</xsl:if>
					<xsl:if test="not(child::*[local-name()='DosageText']) and not(child::*[local-name()='IntendedDuration'])">&#160;</xsl:if>
					<xsl:comment></xsl:comment>
				</div>
			</div>
		</xsl:if>

		<xsl:if test="//child::*[local-name()='Medication']/child::*[local-name()='Comment']">
			<div class="eh-col-2 eh-field {$striped}">
				<div class="eh-text">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="child::*[local-name()='Comment']"/>
					</xsl:call-template>
					<xsl:comment></xsl:comment>
				</div>
			</div>
		</xsl:if>

		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Medication']]/child::*[local-name()='StartDateTime']">
			<div class="eh-col-1-md eh-field {$striped}">
				<div class="eh-text">
					<xsl:choose>
						<xsl:when test="../child::*[local-name()='StartDateTime']/@V"> <!-- kith:TS -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='StartDateTime']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise> <!-- dateTime, date, etc. -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='StartDateTime']"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:comment></xsl:comment>
				</div>
			</div>
		</xsl:if>

		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Medication']]/child::*[local-name()='EndDateTime']">
			<div class="eh-col-1-md eh-field {$striped}">
				<div class="eh-text">
					<xsl:choose>
						<xsl:when test="../child::*[local-name()='EndDateTime']/@V"> <!-- kith:TS -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='EndDateTime']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise> <!-- dateTime, date, etc. -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='EndDateTime']"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:comment></xsl:comment>
				</div>
			</div>
		</xsl:if>

		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='Medication']]/child::*[local-name()='OrgDate']">
			<div class="eh-col-1-md eh-field eh-last-child {$striped}">
				<div class="eh-text">
					<xsl:choose>
						<xsl:when test="../child::*[local-name()='OrgDate']/@V"> <!-- kith:TS -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='OrgDate']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise> <!-- dateTime, date, etc. -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='OrgDate']"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:comment></xsl:comment>
				</div>
			</div>
		</xsl:if>

	</xsl:template>

	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:template name="eh-ResultItem">
		<!-- Henvisning v2.0 			MsgHead/Document/RefDoc/Content/Henvisning/InfItem/ResultItem  -->
		<!-- Henvisning v1.0, v1.1 		Message/ServReq/Patient/InfItem/ResultItem -->
		<!-- merk: rad-element ikke inkludert her. -->
		<!-- Kan brukes av Henvisning, Epikrise, Svarrapport m.fl? -->
		<!-- <div class="eh-col-1 eh-field"> -->
		<xsl:param name="striped" />

			<xsl:variable name="stripedCss">
				<xsl:choose>
					<xsl:when test="$striped = 'true'">striped</xsl:when>
				<xsl:otherwise></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<div class="eh-col-1 eh-field {$stripedCss}">
				<xsl:if test="position()=1"><div class="eh-label">Undersøkelse</div></xsl:if>
				<div class="eh-text">
					<xsl:for-each select="child::*[local-name()='ClinInv']">
						<xsl:for-each select="child::*[local-name()='Id']"> 	<!-- minOccurs="1" -->
							<xsl:call-template name="k-dummy"/>
						</xsl:for-each>
						<xsl:for-each select="child::*[local-name()='Spec']"> 	<!-- maxOccurs="unbounded" -->
							<br/>
							<b>Spesifisert:</b>&#160;
							<xsl:call-template name="k-dummy"/>
						</xsl:for-each>
					</xsl:for-each>
					<xsl:comment></xsl:comment>
				</div>
			</div>

		<div class="eh-col-3 eh-field {$stripedCss}">
			<xsl:if test="position()=1"><div class="eh-label">Funn/resultat</div></xsl:if>
			<div class="eh-text">
				<xsl:for-each select="child::*[local-name()='Interval']">
					<xsl:if test="child::*[local-name()='Low']">
						<b>Nedre:</b>&#160;<xsl:value-of select="child::*[local-name()='Low']/@V"/>
						<xsl:value-of select="child::*[local-name()='Low']/@U"/>&#160;
					</xsl:if>
					<xsl:if test="child::*[local-name()='High']">
						<b>Øvre:</b>&#160;<xsl:value-of select="child::*[local-name()='High']/@V"/>
						<xsl:value-of select="child::*[local-name()='High']/@U"/>&#160;
					</xsl:if>
				</xsl:for-each>

				<xsl:for-each select="child::*[local-name()='DateResult']">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='DateResultValue']/@V"> <!-- kith:TS -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='DateResultValue']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise> <!-- dateTime, date, etc. -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='DateResultValue']"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>

				<xsl:for-each select="child::*[local-name()='NumResult']">
					<xsl:for-each select="child::*[local-name()='ArithmeticComp']">
						<xsl:call-template name="k-8239"/>
					</xsl:for-each>
					<xsl:value-of select="child::*[local-name()='NumResultValue']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='NumResultValue']/@U"/>&#160;
					<xsl:for-each select="../child::*[local-name()='DevResultInd']">
						<b style="color:red;">
							<xsl:call-template name="k-8244"/>
						</b>
					</xsl:for-each>
				</xsl:for-each>

				<xsl:for-each select="child::*[local-name()='TextResult']/child::*[local-name()='Result']">

					<xsl:if test="child::*[local-name()='TextResultValue']"> <!--  type="kith:ST" eller "anyType" -->
						<xsl:choose>
							<xsl:when test="child::*[local-name()='TextResultValue']/child::*[1][namespace-uri()='http://www.w3.org/1999/xhtml']">
								<xsl:copy-of select="child::*[local-name()='TextResultValue']/child::*[1]"/>
							</xsl:when>
							<xsl:when test="child::*[local-name()='TextResultValue'][count(child::*)>0]">
								<xsl:copy-of select="child::*[local-name()='TextResultValue']/node()"/>
							</xsl:when>
							<xsl:otherwise>
								<div>
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="child::*[local-name()='TextResultValue']"/>
									</xsl:call-template>
								</div>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="child::*[local-name()='TextCode']">
						<xsl:for-each select="child::*[local-name()='TextCode']">
							<div>
								<xsl:call-template name="k-dummy"/>
							</div>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>

				<xsl:if test="child::*[local-name()='Comment']">
					<div>
						<b>Kommentar:</b>&#160;<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Comment']"/>
						</xsl:call-template>
					</div>
				</xsl:if>
				<xsl:comment></xsl:comment>
			</div>
		</div>

		<xsl:if test="//child::*[local-name()='ResultItem']/child::*[local-name()='InvDate']">
			<div class="eh-col-1 eh-field">
				<xsl:if test="position()=1"><div class="eh-label">Tidspunkt for undersøkelsen</div></xsl:if>
				<div class="eh-text">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='InvDate']/@V"> <!-- kith:TS -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='InvDate']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise> <!-- dateTime, date, etc. -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='InvDate']"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:comment></xsl:comment>
				</div>
			</div>
		</xsl:if>


		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='StartDateTime']"> <!-- up one level : InfItem -->
			<div class="eh-col-1 eh-field">
				<xsl:if test="position()=1"><div class="eh-label">Starttidspunkt</div></xsl:if>
				<div class="eh-text">
					<xsl:choose>
						<xsl:when test="../child::*[local-name()='StartDateTime']/@V"> <!-- kith:TS -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='StartDateTime']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise> <!-- dateTime, date, etc. -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='StartDateTime']"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:comment></xsl:comment>
				</div>
			</div>
		</xsl:if>

		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='EndDateTime']"> <!-- up one level : InfItem -->
			<div class="eh-col-1 eh-field">
				<xsl:if test="position()=1"><div class="eh-label">Sluttidspunkt</div></xsl:if>
				<div class="eh-text">
					<xsl:choose>
						<xsl:when test="../child::*[local-name()='EndDateTime']/@V"> <!-- kith:TS -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='EndDateTime']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise> <!-- dateTime, date, etc. -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='EndDateTime']"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:comment></xsl:comment>
				</div>
			</div>
		</xsl:if>

		<xsl:if test="//child::*[local-name()='InfItem'][child::*[local-name()='ResultItem']]/child::*[local-name()='OrgDate']"> <!-- up one level : InfItem -->
			<div class="eh-col-1 eh-field eh-last-child">
				<xsl:if test="position()=1"><div class="eh-label">Tidspunkt for opprinnelse</div></xsl:if>
				<div class="eh-text">
					<xsl:choose>
						<xsl:when test="../child::*[local-name()='OrgDate']/@V"> <!-- kith:TS -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='OrgDate']/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise> <!-- dateTime, date, etc. -->
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='OrgDate']"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:comment></xsl:comment>
				</div>
			</div>
		</xsl:if>

	</xsl:template>

	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:template name="eh-ReasonAsText"> <!-- maxOccurs="unbounded" -->
		<!-- Henvisning v2.0 					MsgHead/Document/RefDoc/Content/Henvisning/ReasonAsText  -->
		<!-- Henvisning v1.0, v1.1 				Message/ServReq/ReasonAsText -->
		<!-- Epikrise v1.0, v1.1, v1.2 (ikke i bruk)	Message/ServRprt/ServReq/ReasonAsText -->
		<div  class="eh-row-4">
			<xsl:choose>
				<xsl:when test="child::*[local-name()='Heading']/@V='BG' or  child::*[local-name()='Heading']/@V='BUP-BM' or child::*[local-name()='Heading']/@V='BUP-HG' or child::*[local-name()='Heading']/@V='KF' or child::*[local-name()='Heading']/@V='MAAL' or child::*[local-name()='Heading']/@V='MU' or child::*[local-name()='Heading']/@V='RU' or child::*[local-name()='Heading']/@V='UP'">
					<div class="eh-col-1">
						<div class="eh-label">
							<xsl:for-each select="child::*[local-name()='Heading']">
								<xsl:call-template name="k-8231"/>
							</xsl:for-each>
							<xsl:if test="not(child::*[local-name()='Heading'])">Begrunnelse (uspes.)</xsl:if>
						</div>
					</div>
				</xsl:when>
				<xsl:when test="not(child::*[local-name()='Heading'])">
					<div class="eh-col-1"><div class="eh-label">Begrunnelse (uspes.)</div></div>
				</xsl:when>
			</xsl:choose>

			<div class="eh-col-1 eh-last-child">
				<div class="eh-field">
					<xsl:if test="child::*[local-name()='TextResultValue']"> <!--  type="kith:ST" eller "anyType" -->
						<xsl:choose>
							<xsl:when test="child::*[local-name()='TextResultValue']/child::*[1][namespace-uri()='http://www.w3.org/1999/xhtml']">
								<xsl:copy-of select="child::*[local-name()='TextResultValue']/child::*[1]"/>
							</xsl:when>
							<xsl:when test="child::*[local-name()='TextResultValue'][count(child::*)>0]">
								<xsl:copy-of select="child::*[local-name()='TextResultValue']/node()"/>
							</xsl:when>
							<xsl:otherwise>
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="child::*[local-name()='TextResultValue']"/>
									</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:for-each select="child::*[local-name()='TextCode'] | child::*[local-name()='TextCode']"> <!-- maxOccurs="unbounded" -->
						<xsl:if test="position() &gt; 1">
							<br/>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="@DN">&#160;<xsl:value-of select="@DN"/>&#160;</xsl:when>
							<xsl:when test="@OT">&#160;<xsl:value-of select="@OT"/>&#160;</xsl:when>
							<xsl:when test="@V">
								<xsl:value-of select="@V"/>&#160;<xsl:choose>
									<xsl:when test="contains(@S,'7010')">(SNOMED)</xsl:when>
									<xsl:when test="contains(@S,'7230')">(NKKKL)</xsl:when>
									<xsl:when test="contains(@S,'7240')">(NORAKO)</xsl:when>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:template name="eh-AssistertKommunikasjon"> <!-- maxOccurs="unbounded" -->
		<!-- Henvisning v1.1 		Message/ServReq/Patient/AssistertKommunikasjon -->
		<!-- Kan brukes av Henvisning v1.1 og PLO -->
		<xsl:if test="position()=1">
			<div class="eh-row-8">
				<div class="eh-col-1 eh-label">Behov for tolk</div>
				<xsl:if test="..//child::*[local-name()='AssistertKommunikasjon']/child::*[local-name()='PersonTolkebehov']">
					<div class="eh-col-1 md eh-label">Personen behovet gjelder</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='AssistertKommunikasjon'][child::*[local-name()='Horselsvikt']='true'] or ..//child::*[local-name()='AssistertKommunikasjon'][child::*[local-name()='Synsvikt']='true']">
					<div class="eh-col-1 md eh-label">Handikap</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='AssistertKommunikasjon']/child::*[local-name()='BehovTolkSprak']">
					<div class="eh-col-1 md eh-label">Behov for tolk - Språk</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='AssistertKommunikasjon']/child::*[local-name()='PreferertTolk']">
					<div class="eh-col-1 md eh-label">Foretrukket tolk</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='AssistertKommunikasjon']/child::*[local-name()='BehovOpphortDato']">
					<div class="eh-col-1 md eh-label">Behov opphørt dato</div>
				</xsl:if>
				<xsl:if test="..//child::*[local-name()='AssistertKommunikasjon']/child::*[local-name()='Merknad']">
					<div class="eh-col-1 md eh-last-child eh-label">Merknad</div>
				</xsl:if>
			</div>
		</xsl:if>
		<div class="eh-row-8">
			<div class="eh-col-1 md eh-label">&#160;</div>
			<xsl:if test="..//child::*[local-name()='AssistertKommunikasjon']/child::*[local-name()='PersonTolkebehov']">
				<div class="eh-col-1 eh-field">
					<div class="eh-label xs">Personen behovet gjelder</div>
					<div class="eh-text">
						<xsl:for-each select="child::*[local-name()='PersonTolkebehov']">
							<div>
								<xsl:value-of select="fk1:FamilyName"/>,&#160;<xsl:value-of select="fk1:GivenName"/>&#160;<xsl:value-of select="fk1:MiddleName"/>
							</div>
							<xsl:for-each select=".//fk1:TeleAddress">
								<xsl:call-template name="eh-TeleAddressHode"/>
							</xsl:for-each>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="..//child::*[local-name()='AssistertKommunikasjon'][child::*[local-name()='Horselsvikt']='true'] or ..//child::*[local-name()='AssistertKommunikasjon'][child::*[local-name()='Synsvikt']='true']">
				<div class="eh-col-1 eh-field">
					<div class="eh-label xs">Handikap</div>
					<div class="eh-text">
						<xsl:if test="child::*[local-name()='Horselsvikt']='true'">Døv</xsl:if>
						<xsl:if test="child::*[local-name()='Horselsvikt']='true' and child::*[local-name()='Synsvikt']='true'">&#160;og&#160;</xsl:if>
						<xsl:if test="child::*[local-name()='Synsvikt']='true'">Blind</xsl:if>&#160;
					</div>
				</div>
			</xsl:if>
			<xsl:if test="..//child::*[local-name()='AssistertKommunikasjon']/child::*[local-name()='BehovTolkSprak']">
				<div class="eh-col-1 eh-field">
					<div class="eh-label xs">Behov for tolk - Spr&#197;k</div>
					<div class="eh-text">
						<xsl:for-each select="child::*[local-name()='BehovTolkSprak']">
							<xsl:call-template name="k-3303"/>&#160;
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="..//child::*[local-name()='AssistertKommunikasjon']/child::*[local-name()='PreferertTolk']">
				<div class="eh-col-1 eh-field">
					<div class="eh-label xs">Foretrukket tolk</div>
					<div class="eh-text">
						<xsl:for-each select="child::*[local-name()='PreferertTolk']">
							<div>
								<xsl:value-of select="fk1:FamilyName"/>,&#160;<xsl:value-of select="fk1:GivenName"/>&#160;<xsl:value-of select="fk1:MiddleName"/>
							</div>
							<xsl:for-each select=".//fk1:TeleAddress">
								<xsl:call-template name="eh-TeleAddressHode"/>
							</xsl:for-each>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="..//child::*[local-name()='AssistertKommunikasjon']/child::*[local-name()='BehovOpphortDato']">
				<div class="eh-col-1 eh-field">
					<div class="eh-label xs">Behov opph&#248;rt dato</div>
					<div class="eh-text">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='BehovOpphortDato']/@V"> <!-- kith:TS -->
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='BehovOpphortDato']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise> <!-- dateTime, date, etc. -->
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='BehovOpphortDato']"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="..//child::*[local-name()='AssistertKommunikasjon']/child::*[local-name()='Merknad']">
				<div class="eh-col-1 eh-last-child eh-field">
					<div class="eh-label xs">Merknad</div>
					<div class="eh-text">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->

	<!-- Visning av vedlegg -->
	<xsl:template name="eh-RefDoc">
		<!-- Epikrise v1.0, v1.1, v1.2 -->
		<!-- Henvisning v1.0, v1.1 -->
		<!-- Svarrapport : Message/ServReport/RefDoc -->
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='MsgType'] or child::*[local-name()='Id'] or child::*[local-name()='IssueDate'] or child::*[local-name()='MimeType'] or child::*[local-name()='Compression']">
			<div class="eh-row-5">
				<xsl:if test="child::*[local-name()='MsgType']">
					<div class="eh-col-1">
						<div class="eh-label">Type</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='MsgType']">
								<xsl:choose>
									<xsl:when test="namespace-uri() = 'http://www.kith.no/xmlstds/henvisning/2012-02-15'">
										<xsl:call-template name="k-8114"/> <!-- v1.1 -->
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="k-8263"/> <!-- v1.0 -->
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Id']">
					<div class="eh-col-1">
						<div class="eh-label">Id</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='IssueDate']">
					<div class="eh-col-1">
						<div class="eh-label">Utstedt-dato</div>
						<div class="eh-field blk">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='IssueDate']/@V"> <!-- kith:TS -->
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='IssueDate']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise> <!-- dateTime, date, etc. -->
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='IssueDate']"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>

				<xsl:if test="child::*[local-name()='MimeType']">
					<div class="eh-col-1">
						<div class="eh-label">Mimetype</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='MimeType']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Compression']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Komprimering</div>
						<div class="eh-field blk">
							<xsl:for-each select="child::*[local-name()='Compression']">
								<xsl:call-template name="k-1204"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
			<xsl:if test="child::*[local-name()='Booking']"> <!-- Henvisning v1.0 only -->
				<div class="eh-row-4">
					<div class="eh-col-1">
						<div class="eh-label">Booking</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Booking']">
								<xsl:value-of select="child::*[local-name()='Name']"/>&#8200;
								<b>
									<xsl:choose>
										<xsl:when test="child::*[local-name()='TypeId']/@V">
											<xsl:value-of select="child::*[local-name()='TypeId']/@V"/>:
										</xsl:when>
										<xsl:otherwise>Id:</xsl:otherwise>
									</xsl:choose>
								</b>&#8200;
								<xsl:value-of select="child::*[local-name()='Id']"/>
								<xsl:for-each select=".//child::*[local-name()='SubOrg']">
									<xsl:call-template name="eh-SubOrg" />
								</xsl:for-each>
							</xsl:for-each>
						</div>
					</div>
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Avtale</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Booking']/child::*[local-name()='Appointment']">
								<div>
									<b>Tidspunkt: </b>
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
									<b> til </b>
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']/@V"/>
										<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
									</xsl:call-template>
								</div>
								<div>
									<b> Ressurs: </b>
									<xsl:value-of select="child::*[local-name()='ResourceId']"/>
									<b> Index: </b>
									<xsl:value-of select="child::*[local-name()='Index']"/>
								</div>
								<div>
									<b> Service: </b>
									<xsl:for-each select="child::*[local-name()='Service']">
										<xsl:call-template name="k-8264"/>
									</xsl:for-each>
								</div>
							</xsl:for-each>
						</div>
					</div>
				</div>
			</xsl:if>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Description']">
			<div class="eh-row-4 blk-cmt">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Beskrivelse</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Description']"/>
						</xsl:call-template>
					</div>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Content'] or child::*[local-name()='FileReference']"> <!-- v1.1 only -->
			<xsl:choose>
				<xsl:when test="contains(child::*[local-name()='MimeType'],'image')">
					<div class="eh-row-8">
						<div class="eh-col-1 eh-label">Bilde</div>
						<div class="eh-col-1 eh-field eh-last-child">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='FileReference']">
									<img style="max-width: 100%;">
										<xsl:attribute name="src"><xsl:value-of select="child::*[local-name()='FileReference']"/></xsl:attribute>
										<xsl:attribute name="alt">Bilde fra ekstern URL</xsl:attribute>
									</img>
								</xsl:when>
								<xsl:when test="child::*[local-name()='Content']">
									<xsl:choose>
										<xsl:when test="child::*[local-name()='Content']/base:Base64Container">
											<img style="max-width: 100%;">
												<xsl:attribute name="src"><xsl:value-of select="concat('data:',child::*[local-name()='MimeType'],';base64,',child::*[local-name()='Content']/base:Base64Container)"/></xsl:attribute>
												<xsl:attribute name="alt">Bilde vedlagt som base64-kode</xsl:attribute>
											</img>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="child::*[local-name()='Content']"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
							</xsl:choose>
						</div>
					</div>
				</xsl:when>
				<xsl:when test="contains(child::*[local-name()='MimeType'],'pdf') or contains(child::*[local-name()='MimeType'],'PDF')">
					<div class="eh-row-4 blk-cmt">
						<div class="eh-col-1 eh-last-child">
							<div class="eh-label">PDF</div>
							<div class="eh-field">Hvis du ikke ser pdf-vedlegget kan du prøve en annen nettleser.</div>
						</div>
					</div>
					<div class="eh-row-8 NoPrint">
						<div class="eh-col-1 md eh-field">&#160;</div>
						<div class="eh-col-1 eh-field">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='FileReference']">
									<object>
										<xsl:attribute name="data">
											<xsl:value-of select="concat(child::*[local-name()='FileReference'],'&#35;view&#61;FitH&#38;toolbar&#61;1')"/>
										</xsl:attribute>
										<xsl:attribute name="type">application/pdf</xsl:attribute>
										<xsl:attribute name="width">100%</xsl:attribute>
										<xsl:attribute name="height">500px</xsl:attribute>
									</object>
								</xsl:when>
								<xsl:when test="child::*[local-name()='Content']">
									<xsl:choose>
										<xsl:when test="child::*[local-name()='Content']/base:Base64Container">
											<object>
												<xsl:attribute name="data">
													<xsl:value-of select="concat('data:application/pdf;base64,',child::*[local-name()='Content']/base:Base64Container)"/>
												</xsl:attribute>
												<xsl:attribute name="type">application/pdf</xsl:attribute>
												<xsl:attribute name="width">100%</xsl:attribute>
												<xsl:attribute name="height">500px</xsl:attribute>
											</object>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="child::*[local-name()='Content']"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
							</xsl:choose>
						</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="eh-row-4">
						<div class="eh-col-1 eh-last-field">
							<div class="eh-field">
								<xsl:choose>
									<xsl:when test="child::*[local-name()='Content']">
										<xsl:value-of select="child::*[local-name()='Content']"/>
									</xsl:when>
									<xsl:when test="child::*[local-name()='FileReference']">
										<xsl:value-of select="child::*[local-name()='FileReference']"/>
									</xsl:when>
								</xsl:choose>
							</div>
						</div>
					</div>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->

	<!-- Visning av vedlegg -->
	<xsl:template name="eh-msghead-RefDoc">
		<!-- felleskomponent : MsgHead/Document/RefDoc -->
		<!-- Henvisning v2.0 -->
		<xsl:if test="mh:MsgType or mh:Id or mh:IssueDate or mh:MimeType or mh:Compression">
			<div class="eh-row-5">
				<xsl:if test="mh:MsgType">
					<div class="eh-col-1">
						<div class="eh-label">Type</div>
						<div class="eh-field">
							<xsl:for-each select="mh:MsgType">
								<xsl:call-template name="k-8114"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="mh:Id">
					<div class="eh-col-1">
						<div class="eh-label">Id</div>
						<div class="eh-field">
							<xsl:value-of select="mh:Id"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="mh:IssueDate">
					<div class="eh-col-1">
						<div class="eh-label">Utstedt-dato</div>
						<div class="eh-field blk">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="mh:IssueDate/@V"/>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="mh:MimeType">
					<div class="eh-col-1">
						<div class="eh-label">Mimetype</div>
						<div class="eh-field">
							<xsl:value-of select="mh:MimeType"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="mh:Compression">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Komprimering</div>
						<div class="eh-field blk">
							<xsl:for-each select="mh:Compression">
								<xsl:call-template name="k-1204"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:if test="mh:Description">
			<div class="eh-row-4 blk-cmt">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Beskrivelse</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="mh:Description"/>
						</xsl:call-template>
					</div>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="mh:Content or mh:FileReference">
			<xsl:choose>
				<xsl:when test="contains(mh:MimeType,'image')">
					<div class="eh-row-8">
						<div class="eh-col-1 eh-label">Bilde</div>
						<div class="eh-col-1 eh-field eh-last-child">
								<xsl:choose>
									<xsl:when test="mh:FileReference">
										<img style="max-width: 100%;">
											<xsl:attribute name="src"><xsl:value-of select="mh:FileReference"/></xsl:attribute>
											<xsl:attribute name="alt">Bilde fra ekstern URL</xsl:attribute>
										</img>
									</xsl:when>
									<xsl:when test="mh:Content">
										<xsl:choose>
											<xsl:when test="mh:Content/base:Base64Container">
												<img style="max-width: 100%;">
													<xsl:attribute name="src"><xsl:value-of select="concat('data:',mh:MimeType,';base64,',mh:Content/base:Base64Container)"/></xsl:attribute>
													<xsl:attribute name="alt">Bilde vedlagt som base64-kode</xsl:attribute>
												</img>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="mh:Content"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
								</xsl:choose>
						</div>
					</div>
				</xsl:when>
				<xsl:when test="contains(mh:MimeType,'pdf') or contains(mh:MimeType,'PDF')">
					<div class="eh-row-4 blk-cmt">
						<div class="eh-col-1 eh-last-child">
							<div class="eh-label">pdf</div>
							<div class="eh-field">Hvis du ikke ser pdf-vedlegget kan du prøve en annen nettleser.</div>
						</div>
					</div>
					<div class="eh-row-8 NoPrint">
						<div class="eh-col-1 md eh-field">&#160;</div>
						<div class="eh-col-1 eh-field">
								<xsl:choose>
									<xsl:when test="mh:FileReference">
										<object>
											<xsl:attribute name="data"><xsl:value-of select="concat(mh:FileReference,'&#35;view&#61;FitH&#38;toolbar&#61;1')"/></xsl:attribute>
											<xsl:attribute name="type">application/pdf</xsl:attribute>
											<xsl:attribute name="width">100%</xsl:attribute>
											<xsl:attribute name="height">500px</xsl:attribute>
										</object>
									</xsl:when>
									<xsl:when test="mh:Content">
										<xsl:choose>
											<xsl:when test="mh:Content/base:Base64Container">
												<object>
													<xsl:attribute name="data"><xsl:value-of select="concat('data:application/pdf;base64,',mh:Content/base:Base64Container)"/></xsl:attribute>
													<xsl:attribute name="type">application/pdf</xsl:attribute>
													<xsl:attribute name="width">100%</xsl:attribute>
													<xsl:attribute name="height">500px</xsl:attribute>
												</object>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="mh:Content"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
								</xsl:choose>
						</div>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="eh-row-4">
						<div class="eh-col-1 eh-last-child">
							<div class="eh-field">
								<xsl:choose>
									<xsl:when test="mh:Content">
										<xsl:value-of select="mh:Content"/>
									</xsl:when>
									<xsl:when test="mh:FileReference">
										<xsl:value-of select="mh:FileReference"/>
									</xsl:when>
								</xsl:choose>
							</div>
						</div>
					</div>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:template name="eh-SubOrg"> <!-- Henvisning v1.0  -->
		<div>
			<xsl:value-of select="child::*[local-name()='Name']"/>&#8200;
			<b>
				<xsl:choose>
					<xsl:when test="child::*[local-name()='TypeId']">
						<xsl:value-of select="child::*[local-name()='TypeId']"/>:</xsl:when>
					<xsl:otherwise>Id:</xsl:otherwise>
				</xsl:choose>
			</b>&#8200;
			<xsl:value-of select="child::*[local-name()='Id']"/>
		</div>
	</xsl:template>

	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:template name="eh-Address" >
		<xsl:if test="child::*[local-name()='StreetAdr'] or child::*[local-name()='PostalCode'] or child::*[local-name()='City'] or child::*[local-name()='CityDistr'] or child::*[local-name()='County'] or child::*[local-name()='Country']">
			<xsl:if test="child::*[local-name()='Type']">
				<b>
					<xsl:for-each select="child::*[local-name()='Type']">
						<xsl:call-template name="k-3401"/>:&#160;
					</xsl:for-each>
				</b>
			</xsl:if>
		</xsl:if>
		<xsl:if test="child::*[local-name()='StreetAdr']">
			<xsl:value-of select="child::*[local-name()='StreetAdr']"/>
		</xsl:if>
		<xsl:if test="child::*[local-name()='PostalCode'] or child::*[local-name()='City']">
			<xsl:if test="child::*[local-name()='StreetAdr']">, </xsl:if>
			<xsl:value-of select="child::*[local-name()='PostalCode']"/>&#8200;<xsl:value-of select="child::*[local-name()='City']"/>
		</xsl:if>
		<xsl:if test="child::*[local-name()='CityDistr']">, <xsl:for-each select="child::*[local-name()='CityDistr']">
				<xsl:call-template name="k-3403"/>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="child::*[local-name()='County']">, <xsl:for-each select="child::*[local-name()='County']">
				<xsl:call-template name="k-3402"/>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Country']">, <xsl:for-each select="child::*[local-name()='Country']">
				<xsl:call-template name="k-9043"/>
			</xsl:for-each>
		</xsl:if>
		<xsl:for-each select="child::*[local-name()='TeleAddress']">
			<xsl:call-template name="eh-TeleAddressHode"/>
		</xsl:for-each>
	</xsl:template>

	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:template name="eh-TeleAddress">
		<div class="eh-col-2">
			<div class="eh-label">
				<xsl:choose>
					<xsl:when test="starts-with(@V, 'tel:') or starts-with(@V, 'callto:')">Telefon</xsl:when>
					<xsl:when test="starts-with(@V, 'fax:')">Faks</xsl:when>
					<xsl:when test="starts-with(@V, 'mailto:')">e-post</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-before(@V, ':')"/>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="eh-field">
				<xsl:value-of select="substring-after(@V, ':')"/>
			</div>
		</div>
	</xsl:template>

	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:template name="eh-TeleAddressHode">
		<div>
			<b>
				<xsl:choose>
					<xsl:when test="starts-with(@V, 'tel:') or starts-with(@V, 'callto:')">Telefon</xsl:when>
					<xsl:when test="starts-with(@V, 'fax:')">Faks</xsl:when>
					<xsl:when test="starts-with(@V, 'mailto:')">e-post</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-before(@V, ':')"/>
					</xsl:otherwise>
				</xsl:choose>
			</b>:&#160;<xsl:value-of select="substring-after(@V, ':')"/>
		</div>
	</xsl:template>

	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:template name="Footer">
		<xsl:param name="stil"/>
		<xsl:param name="versjon"/>
		<xsl:param name="VisDokInfoVisSkjul"/>

		<footer class="{$stil}">
			<h2>Dokumentinformasjon</h2>

			<xsl:if test="$VisDokInfoVisSkjul">
				<label for="visFooter" class="VisSkjul">Vis/Skjul</label>
				<input type="checkbox" checked="true" id="visFooter" style="display: none;"/>
			</xsl:if>

			<div class="eh-section">
				<div class="eh-row-4">
					<div class="eh-col-1">
						<div class="eh-label">Melding opprettet</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid">
									<xsl:choose>
										<xsl:when test="local-name()='ServReq'">
											<xsl:value-of select="../child::*[local-name()='GenDate']" />	<!-- /Message/GenDate -->
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="/descendant::mh:GenDate[1]" />	<!-- /MsgHead/MsgInfo/GenDate -->
										</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
								<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
							</xsl:call-template>
						</div>
					</div>
					<xsl:if test="child::*[local-name()='IssueDate']">
						<div class="eh-col-1">
							<div class="eh-label">Melding utstedt</div>
							<div class="eh-field">
								<xsl:choose>
									<xsl:when test="child::*[local-name()='IssueDate']/@V"> <!-- kith:TS -->
										<xsl:call-template name="skrivUtTS">
											<xsl:with-param name="oppgittTid" select="child::*[local-name()='IssueDate']/@V"/>
											<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise> <!-- dateTime, date, etc. -->
										<xsl:call-template name="skrivUtTS">
											<xsl:with-param name="oppgittTid" select="child::*[local-name()='IssueDate']"/>
											<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='ApprDate']">
						<div class="eh-col-1">
							<div class="eh-label">Melding godkjent</div>
							<div class="eh-field">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='ApprDate']/@V"/>
									<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
								</xsl:call-template>
							</div>
						</div>
					</xsl:if>
				</div>
 				<div class="eh-row-4">
				 	<div class="eh-col-1">
						<div class="eh-label">Visningsversjon</div>
						<div class="eh-field"><xsl:value-of select="$versjon"/></div>
					</div>
					<div class="eh-col-1">
						<div class="eh-label">Visningsstil</div>
						<div class="eh-field"><xsl:value-of select="$stil"/></div>
					</div>
					<xsl:if test="/descendant::mh:MsgVersion or /descendant::mh:MIGversion">
						<div class="eh-col-1">
							<div class="eh-label">Meldingsversjon</div>
							<div class="eh-field">
								<xsl:value-of select="/descendant::mh:Type/@DN"/>
								<xsl:text>&#160;</xsl:text>
								<xsl:choose>
									<xsl:when test="/descendant::mh:MsgVersion">
										<xsl:value-of select="/descendant::mh:MsgVersion[1]"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="/descendant::mh:MIGversion[1]"/>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</div>
					</xsl:if>
				</div>
 				<div class="eh-row-4">
					<xsl:call-template name="EgetBunnTillegg"/>
				 	<xsl:if test="child::*[local-name()='Priority']">
						<div class="eh-col-1">
							<div class="eh-label">Hastegrad</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='Priority']">
									<xsl:call-template name="k-7303"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
					<!-- <xsl:if test="child::*[local-name()='Ack']">
						<div class="eh-col-1">
							<div class="eh-label">Meldingsbekreftelse</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='Ack']">
									<xsl:call-template name="k-7304"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if> -->
					<div class="eh-col-1">
						<div class="eh-label">Meldingsid</div>
						<div class="eh-field">
							<xsl:choose>
 								<xsl:when test="local-name()='ServReq'">
  									<xsl:value-of select="../child::*[local-name()='MsgId']" />	<!-- /Message/MsgId -->
   								</xsl:when>
   								<xsl:otherwise>
  									<xsl:value-of select="/descendant::mh:MsgId[1]" />	<!-- /MsgHead/MsgInfo/MsgId -->
   								</xsl:otherwise>
  							</xsl:choose>
						</div>
					</div>
				</div>
			</div>
		</footer>
	</xsl:template>

	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:template name="eh-Pakkeforlop"> <!-- Henvisning 2.0/Pakkeforlop -->
		<xsl:param name="striped" />

		<div class="eh-col-1 eh-field {$striped}">
			<div class="eh-text">
				<xsl:value-of select="child::*[local-name()='Pakkeforlopskode']/@V"/>
			</div>
		</div>

		<div class="eh-col-2 eh-field {$striped}">
			<div class="eh-text">
				<xsl:for-each select="child::*[local-name()='Pakkeforlopskode']">
					<xsl:choose>
						<xsl:when test="contains(@S,'8480')">
							<xsl:call-template name="k-8480"/>
						</xsl:when>
						<xsl:when test="contains(@S,'9173')">
							<xsl:call-template name="k-9173"/>
						</xsl:when>
						<xsl:when test="contains(@S,'9174')">
							<xsl:call-template name="k-9174"/>
						</xsl:when>
						<xsl:when test="contains(@S,'9175')">
							<xsl:call-template name="k-9175"/>
						</xsl:when>
						<xsl:when test="contains(@S,'9176')">
							<xsl:call-template name="k-9176"/>
						</xsl:when>
						<xsl:when test="contains(@S,'9321')">
							<xsl:call-template name="k-9321"/>
						</xsl:when>
						<xsl:when test="contains(@S,'9327')">
							<xsl:call-template name="k-9327"/>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</div>
		</div>

		<div class="eh-col-3 eh-field {$striped}">
			<div class="eh-text">
				<xsl:value-of select="child::*[local-name()='Merknad']"/>
			</div>
		</div>

	</xsl:template>

</xsl:stylesheet>
