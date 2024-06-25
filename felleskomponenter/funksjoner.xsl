<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2013 rel.2  sp.2 (http://www.altova.com) by Jan Sigurd Dragsjø - avd. Standardisering, Helsedirektoratet-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
	xmlns:dt="http://xsltsl.org/date-time"
	exclude-result-prefixes="fo dt">

	<xsl:import href="SourceForge/stdlib.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
	
<!-- Funksjonsfil - importeres av alle visningsfiler -->
<!-- Siste endring:
	-	04.06.21: Lagt til xsl:output for å definere at output formatet skal være html
	-	07.03.17: Lagt til attributt exclude-result-prefix
	-	06.11.13: La til sjekk om tidspunkt ikke har verdi
	-	31.10.13: Endret dateTime-visning i funksjoner.xsl til å følge ISO-8601 -->

	<!-- Funskjon for å få til linjeskift - for bruk ved datatypen ST eller string -->
	<xsl:template name="line-breaks">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text,'&#10;')">
				<xsl:value-of select="substring-before($text,'&#10;')"/>
				<br/>
				<xsl:call-template name="line-breaks">
					<xsl:with-param name="text" select="substring-after($text,'&#10;')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Funksjon for å legge til x antall dager til en angitt dato. Eventuelle oppgitte timer fjernes fra visning -->
	<xsl:template name="skrivUtDateJustert">
		<xsl:param name="oppgittTid"/> <!-- Må oppgis som dato -->
		<xsl:param name="xAntall"/> <!-- Må ikke overskride 28 dager -->
		<xsl:choose>
			<xsl:when test="string-length($oppgittTid) &gt; 0">
				<xsl:choose>
					<xsl:when test="contains($oppgittTid, 'T')"> <!-- Tid oppgitt som dateTime -->
						<xsl:call-template name="skrivUtDateJustert">
							<xsl:with-param name="oppgittTid" select="substring-before($oppgittTid, 'T')"/>
							<xsl:with-param name="xAntall" select="$xAntall"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="antDagerMnd"><xsl:call-template name="dt:calculate-last-day-of-month"><xsl:with-param name="month" select="substring($oppgittTid,6,2)"/><xsl:with-param name="year" select="substring($oppgittTid,1,4)"/></xsl:call-template></xsl:variable>
						<xsl:choose>
							<xsl:when test="substring($oppgittTid,9,2)+$xAntall &lt;= $antDagerMnd"><!-- Sjekker om månedslutt ikke passeres -->
								<xsl:if test="(substring($oppgittTid,9,2)+$xAntall) &lt; 10">0</xsl:if><xsl:value-of select="substring($oppgittTid,9,2)+$xAntall"/>.<xsl:value-of select="substring($oppgittTid,6,2)"/>.<xsl:value-of select="substring($oppgittTid,3,2)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="substring($oppgittTid,6,2) &lt; 12"><!-- Sjekker om nyttår ikke passeres -->
										<xsl:if test="(substring($oppgittTid,9,2)+$xAntall)-$antDagerMnd &lt; 10">0</xsl:if><xsl:value-of select="(substring($oppgittTid,9,2)+$xAntall)-$antDagerMnd"/>.<xsl:if test="(substring($oppgittTid,6,2)+1) &lt; 10">0</xsl:if><xsl:value-of select="substring($oppgittTid,6,2)+1"/>.<xsl:value-of select="substring($oppgittTid,3,2)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:if test="(substring($oppgittTid,9,2)+$xAntall)-$antDagerMnd &lt; 10">0</xsl:if><xsl:value-of select="(substring($oppgittTid,9,2)+$xAntall)-$antDagerMnd"/>.01.<xsl:choose>
											<xsl:when test="number(substring($oppgittTid,3,2)) = 99">00</xsl:when>
											<xsl:otherwise><xsl:if test="(substring($oppgittTid,3,2)+1) &lt; 10">0</xsl:if><xsl:value-of select="substring($oppgittTid,3,2)+1"/></xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>-</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Funksjon som reverserer tilbake til datoformat etter at skrivUtDatoJustert har kjørt. Forutsetter dato i det 21. århundre. -->
	<xsl:template name="skrivUtDateReversert">
		<xsl:param name="oppgittTid"/>20<xsl:value-of select="substring($oppgittTid,7,2)"/>-<xsl:value-of select="substring($oppgittTid,4,2)"/>-<xsl:value-of select="substring($oppgittTid,1,2)"/>
	</xsl:template>
	
	<!-- Funksjon som returnerer ukedag (1-7 hvor 1 = mandag) til gitt dato -->
	<xsl:template name="kalkulerUkedag">
		<xsl:param name="oppgittDato"/> <!-- Dato oppgitt på date eller dateTime- format -->
		<xsl:variable name="ukedag">
			<xsl:call-template name="dt:calculate-day-of-the-week">
				<xsl:with-param name="day" select="substring($oppgittDato,9,2)"/>
				<xsl:with-param name="month" select="substring($oppgittDato,6,2)"/>
				<xsl:with-param name="year" select="substring($oppgittDato,1,4)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$ukedag = 0">7</xsl:when>
			<xsl:otherwise><xsl:value-of select="$ukedag"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Funskjon for å skrive ut tidspunkt oppgitt i TS-element -->
	<xsl:template name="skrivUtTS">
		<xsl:param name="oppgittTid"/>
		<xsl:param name="useNormalSpaceSeparator"/>
		<xsl:choose>
			<xsl:when test="contains($oppgittTid, 'T')"> <!-- Tid oppgitt som dateTime -->
				<xsl:call-template name="skrivUtDateTime">
					<xsl:with-param name="oppgittTid" select="$oppgittTid"/>
					<xsl:with-param name="useNormalSpaceSeparator" select="$useNormalSpaceSeparator"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="substring($oppgittTid,3,1) = ':'"> <!-- Tid oppgitt som time -->
						<xsl:call-template name="skrivUtTime">
							<xsl:with-param name="oppgittTid" select="$oppgittTid"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise> <!-- Tid oppgitt som enten gYear, gYearMonth eller date -->
						<xsl:choose>						
							<xsl:when test="substring($oppgittTid,5,1) = '-' and substring($oppgittTid,8,1) = '-'">
								<xsl:call-template name="skrivUtDate">
									<xsl:with-param name="oppgittTid" select="$oppgittTid"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="substring($oppgittTid,5,1) = '-'">
										<xsl:value-of select="substring($oppgittTid,6,2)"/>.<xsl:value-of select="substring($oppgittTid,3,2)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="substring($oppgittTid,1,4)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Funskjon for å skrive ut tidspunkt oppgitt i time-element -->
	<xsl:template name="skrivUtTime">
		<xsl:param name="oppgittTid"/>
		<xsl:if test="string-length($oppgittTid)!=0">
			kl.<xsl:value-of select="substring($oppgittTid,1,5)"/>
		</xsl:if>
	</xsl:template>
	
	<!-- Funskjon for å skrive ut tidspunkt oppgitt i date-element -->
	<xsl:template name="skrivUtDate">
		<xsl:param name="oppgittTid"/>
		<xsl:if test="string-length($oppgittTid)!=0">
			<xsl:value-of select="substring($oppgittTid,9,2)"/>.<xsl:value-of select="substring($oppgittTid,6,2)"/>.<xsl:value-of select="substring($oppgittTid,3,2)"/>
		</xsl:if>
	</xsl:template>
	
	<!-- Funskjon for å skrive ut tidsperiode oppgitt i duration-element -->
	<xsl:template name="skrivUtDuration">
		<xsl:param name="oppgittPeriode"/>
		<xsl:if test="string-length($oppgittPeriode)!=0">
		<!-- Traversering av streng -->
			<xsl:choose>
				<!-- Negativ tidsperiode -->
				<xsl:when test="starts-with($oppgittPeriode, '-')">
					minus&#160;
					<xsl:call-template name="skrivUtDuration">
						<xsl:with-param name="oppgittPeriode" select="substring-after($oppgittPeriode, '-')"/>
					</xsl:call-template>
				</xsl:when>
				<!-- Fjerner den påkrevde startP'en -->
				<xsl:when test="contains($oppgittPeriode, 'P')">
					<xsl:call-template name="skrivUtDuration">
						<xsl:with-param name="oppgittPeriode" select="substring-after($oppgittPeriode, 'P')"/>
					</xsl:call-template>
				</xsl:when>
				<!-- År -->
				<xsl:when test="contains($oppgittPeriode, 'Y')">
					<xsl:value-of select="substring-before($oppgittPeriode, 'Y')"/>år&#160;
					<xsl:if test="string-length(substring-after($oppgittPeriode, 'Y')) &gt; 0">
						<xsl:call-template name="skrivUtDuration">
							<xsl:with-param name="oppgittPeriode" select="substring-after($oppgittPeriode, 'Y')"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<!-- Måned -->
				<xsl:when test="(not(contains($oppgittPeriode, 'T')) and contains($oppgittPeriode, 'M')) or (contains($oppgittPeriode, 'T') and contains(substring-before($oppgittPeriode, 'T'), 'M'))">
					<xsl:value-of select="substring-before($oppgittPeriode, 'M')"/>mnd&#160;
					<xsl:if test="string-length(substring-after($oppgittPeriode, 'M')) &gt; 0">
						<xsl:call-template name="skrivUtDuration">
							<xsl:with-param name="oppgittPeriode" select="substring-after($oppgittPeriode, 'M')"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<!-- Dag -->
				<xsl:when test="contains($oppgittPeriode, 'D')">
					<xsl:value-of select="substring-before($oppgittPeriode, 'D')"/>
					<xsl:choose>
						<xsl:when test="substring-before($oppgittPeriode, 'D') = '1'">dag</xsl:when>
						<xsl:otherwise>dager</xsl:otherwise>
					</xsl:choose>&#160;
					<xsl:if test="string-length(substring-after($oppgittPeriode, 'D')) &gt; 0">
						<xsl:call-template name="skrivUtDuration">
							<xsl:with-param name="oppgittPeriode" select="substring-after($oppgittPeriode, 'D')"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<!-- Timer -->
				<xsl:when test="contains($oppgittPeriode, 'H')">
					<xsl:value-of select="substring-after(substring-before($oppgittPeriode, 'H'), 'T')"/>
					<xsl:choose>
						<xsl:when test="substring-after(substring-before($oppgittPeriode, 'H'), 'T') = '1'">time</xsl:when>
						<xsl:otherwise>timer</xsl:otherwise>
					</xsl:choose>&#160;
					<xsl:if test="string-length(substring-after($oppgittPeriode, 'H')) &gt; 0">
						<xsl:call-template name="skrivUtDuration">
							<xsl:with-param name="oppgittPeriode" select="concat('T', substring-after($oppgittPeriode, 'H'))"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<!-- Minutt -->
				<xsl:when test="contains($oppgittPeriode, 'M')">
					<xsl:value-of select="substring-after(substring-before($oppgittPeriode, 'M'), 'T')"/>min&#160;
					<xsl:if test="string-length(substring-after($oppgittPeriode, 'M')) &gt; 0">
						<xsl:call-template name="skrivUtDuration">
							<xsl:with-param name="oppgittPeriode" select="concat('T', substring-after($oppgittPeriode, 'M'))"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<!-- Sekund -->
				<xsl:when test="contains($oppgittPeriode, 'S')">
					<xsl:value-of select="substring-after(substring-before($oppgittPeriode, 'S'), 'T')"/>sek&#160;
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<!-- Funskjon for å skrive ut tidspunkt oppgitt i dateTime-element -->
	<!-- Bruk:
	- Håndterer sommertid for tidspunkt oppgitt i UTC/Zulu (Tidspunktet har en 'Z' til slutt). F.eks. vil 2013-05-05T15:30:00Z vises som 2013-05-05 kl.17:30 lokal norsk tid.
	- For tidspunkt oppgitt med eller uten tidssoner (hverken 'Z' eller +/- hh:mm) antas at korrekt lokal tid er oppgitt. F.eks. vil 2013-05-05T15:30:00+02:00 vises som 2013-05-05 kl.15:30 lokal norsk tid.
	- Benytter tilleggs-funksjonen 'sjekkSommertid' som benytter standard biblioteksmodul fra sourceforge.net. Returnerer '1' om oppgitt tidspunkt er innen norsk sommertid - '0' hvis ikke. -->
	<xsl:template name="skrivUtDateTime">
		<xsl:param name="oppgittTid"/>
		<xsl:param name="useNormalSpaceSeparator"/>

		<xsl:variable name="spaceChar">
			<xsl:choose>
				<xsl:when test="not($useNormalSpaceSeparator)">&#160;</xsl:when> <!-- -->
				<xsl:otherwise>&#8200;</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="string-length($oppgittTid)!=0">
			<xsl:choose>
				<xsl:when test="contains($oppgittTid, 'Z')"> <!-- Sjekker om tidspunktet er oppgitt i UTC/Zulu -->
					<xsl:variable name="forskyvning" select="1"/> <!-- Angir Norges tidssone -->
					<xsl:variable name="sommertid">
						<xsl:call-template name="sjekkSommertid"><xsl:with-param name="oppgittTid" select="$oppgittTid"/><xsl:with-param name="forskyvning" select="$forskyvning"/></xsl:call-template>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="substring($oppgittTid,12,2) &lt; (24 - $forskyvning - $sommertid)"><!-- Sjekker om midnatt passeres -->
							<xsl:value-of select="substring($oppgittTid,9,2)"/>.<xsl:value-of select="substring($oppgittTid,6,2)"/>.<xsl:value-of select="substring($oppgittTid,3,2)"/><xsl:value-of select="$spaceChar"/>kl.<xsl:if test="(substring($oppgittTid,12,2) + $forskyvning + $sommertid) &lt; 10">0</xsl:if><xsl:value-of select="substring($oppgittTid,12,2) + $forskyvning + $sommertid"/>:<xsl:value-of select="substring($oppgittTid,15,2)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="antDagerMnd"><xsl:call-template name="dt:calculate-last-day-of-month"><xsl:with-param name="month" select="substring($oppgittTid,6,2)"/><xsl:with-param name="year" select="substring($oppgittTid,1,4)"/></xsl:call-template></xsl:variable>
							<xsl:choose>
								<xsl:when test="substring($oppgittTid,9,2) &lt; $antDagerMnd"><!-- Sjekker om månedslutt passeres -->
									<xsl:if test="(substring($oppgittTid,9,2)+1) &lt; 10">0</xsl:if><xsl:value-of select="substring($oppgittTid,9,2)+1"/>.<xsl:value-of select="substring($oppgittTid,6,2)"/>.<xsl:value-of select="substring($oppgittTid,3,2)"/><xsl:value-of select="$spaceChar"/>kl.<xsl:if test="(substring($oppgittTid,12,2)+$forskyvning+$sommertid)-24  &lt; 10">0</xsl:if><xsl:value-of select="(substring($oppgittTid,12,2)+$forskyvning+$sommertid)-24"/>:<xsl:value-of select="substring($oppgittTid,15,2)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="substring($oppgittTid,6,2) &lt; 12"><!-- Sjekker om nyttår passeres -->
											01.<xsl:if test="(substring($oppgittTid,6,2)+1) &lt; 10">0</xsl:if><xsl:value-of select="substring($oppgittTid,6,2)+1"/>.<xsl:value-of select="substring($oppgittTid,3,2)"/><xsl:value-of select="$spaceChar"/>kl.<xsl:if test="(substring($oppgittTid,12,2)+$forskyvning+$sommertid)-24  &lt; 10">0</xsl:if><xsl:value-of select="(substring($oppgittTid,12,2)+$forskyvning+$sommertid)-24"/>:<xsl:value-of select="substring($oppgittTid,15,2)"/>
										</xsl:when>
										<xsl:otherwise>
											01.01.<xsl:choose>
												<xsl:when test="number(substring($oppgittTid,3,2)) = 99">00</xsl:when>
												<xsl:otherwise><xsl:if test="(substring($oppgittTid,3,2)+1) &lt; 10">0</xsl:if><xsl:value-of select="substring($oppgittTid,3,2)+1"/></xsl:otherwise>
											</xsl:choose><xsl:value-of select="$spaceChar"/>kl.<xsl:if test="(substring($oppgittTid,12,2)+$forskyvning+$sommertid)-24  &lt; 10">0</xsl:if><xsl:value-of select="(substring($oppgittTid,12,2)+$forskyvning+$sommertid)-24"/>:<xsl:value-of select="substring($oppgittTid,15,2)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise> <!-- Antar at lokal tid er oppgitt - gjelder for alle tidspunkt oppgitt med eller uten tidssoneer -->
					<xsl:value-of select="substring($oppgittTid,9,2)"/>.<xsl:value-of select="substring($oppgittTid,6,2)"/>.<xsl:value-of select="substring($oppgittTid,3,2)"/><xsl:value-of select="$spaceChar"/>kl.<xsl:value-of select="substring($oppgittTid,12,5)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="sjekkSommertid">
		<xsl:param name="oppgittTid"/>
		<xsl:param name="forskyvning"/>
		<!-- variabel som inneholder antall dager i oppgitt måned -->
		<xsl:variable name="antDagerMnd"><xsl:call-template name="dt:calculate-last-day-of-month"><xsl:with-param name="month" select="substring($oppgittTid,6,2)"/><xsl:with-param name="year" select="substring($oppgittTid,1,4)"/></xsl:call-template></xsl:variable>
		<!-- variabel som inneholder et tall (0-6 hvor 0 = søndag) som angir hvilken dag som er den siste dagen i oppgitt måned -->
		<xsl:variable name="sisteDagMnd"><xsl:call-template name="dt:calculate-day-of-the-week"><xsl:with-param name="day" select="$antDagerMnd"/><xsl:with-param name="month" select="substring($oppgittTid,6,2)"/><xsl:with-param name="year" select="substring($oppgittTid,1,4)"/></xsl:call-template></xsl:variable>
		<!-- boolsk variabel som er true om oppgitt utc-tidspunkt er innenfor norsk sommertid. ($antDagerMnd - $sisteDagMnd) gir hvilken dato som er siste søndag i oppgitt måned -->
		<xsl:variable name="sommertid" select="not( substring($oppgittTid,6,2) &lt; 3 or substring($oppgittTid,6,2) &gt; 10 or ( substring($oppgittTid,6,2) = 3 and ( (substring($oppgittTid,9,2) &lt; ($antDagerMnd - $sisteDagMnd) ) or ( ( substring($oppgittTid,9,2) = ($antDagerMnd - $sisteDagMnd) ) and substring($oppgittTid,12,2) &lt; (1+$forskyvning) ) ) ) or ( substring($oppgittTid,6,2) = 10 and ( (substring($oppgittTid,9,2) &gt; ($antDagerMnd - $sisteDagMnd) ) or ( ( substring($oppgittTid,9,2) = ($antDagerMnd - $sisteDagMnd) ) and substring($oppgittTid,12,2) &gt; (1-$forskyvning)) ) ) )"/>
		<!-- returnerer 1 hvis sommertid, 0 hvis ikke -->
		<xsl:value-of select="number($sommertid)"/>
	</xsl:template>
	
</xsl:stylesheet>
