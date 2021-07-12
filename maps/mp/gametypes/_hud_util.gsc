// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

#include maps\mp\_utility;

setParent( element )
{
    if ( isdefined( self.parent ) && self.parent == element )
        return;

    if ( isdefined( self.parent ) )
        self.parent removeChild( self );

    self.parent = element;
    self.parent addChild( self );

    if ( isdefined( self.point ) )
        setPoint( self.point, self.relativePoint, self.xOffset, self.yOffset );
    else
        setPoint( "TOPLEFT" );
}

getParent()
{
    return self.parent;
}

addChild( element )
{
    element.index = self.children.size;
    self.children[self.children.size] = element;
}

removeChild( element )
{
    element.parent = undefined;

    if ( self.children[self.children.size - 1] != element )
    {
        self.children[element.index] = self.children[self.children.size - 1];
        self.children[element.index].index = element.index;
    }

    self.children[self.children.size - 1] = undefined;
    element.index = undefined;
}

setPoint( point, relativePoint, xOffset, yOffset, moveTime )
{
    if ( !isdefined( moveTime ) )
        moveTime = 0;

    element = getParent();

    if ( moveTime )
        self moveovertime( moveTime );

    if ( !isdefined( xOffset ) )
        xOffset = 0;

    self.xOffset = xOffset;

    if ( !isdefined( yOffset ) )
        yOffset = 0;

    self.yOffset = yOffset;
    self.point = point;
    self.alignx = "center";
    self.aligny = "middle";

    if ( issubstr( point, "TOP" ) )
        self.aligny = "top";

    if ( issubstr( point, "BOTTOM" ) )
        self.aligny = "bottom";

    if ( issubstr( point, "LEFT" ) )
        self.alignx = "left";

    if ( issubstr( point, "RIGHT" ) )
        self.alignx = "right";

    if ( !isdefined( relativePoint ) )
        relativePoint = point;

    self.relativePoint = relativePoint;
    relativeX = "center_adjustable";
    relativeY = "middle";

    if ( issubstr( relativePoint, "TOP" ) )
        relativeY = "top_adjustable";

    if ( issubstr( relativePoint, "BOTTOM" ) )
        relativeY = "bottom_adjustable";

    if ( issubstr( relativePoint, "LEFT" ) )
        relativeX = "left_adjustable";

    if ( issubstr( relativePoint, "RIGHT" ) )
        relativeX = "right_adjustable";

    if ( element == level.uiParent )
    {
        self.horzalign = relativeX;
        self.vertalign = relativeY;
    }
    else
    {
        self.horzalign = element.horzalign;
        self.vertalign = element.vertalign;
    }

    if ( maps\mp\_utility::strip_suffix( relativeX, "_adjustable" ) == element.alignx )
    {
        offsetX = 0;
        xFactor = 0;
    }
    else if ( relativeX == "center" || element.alignx == "center" )
    {
        offsetX = int( element.width / 2 );

        if ( relativeX == "left_adjustable" || element.alignx == "right" )
            xFactor = -1;
        else
            xFactor = 1;
    }
    else
    {
        offsetX = element.width;

        if ( relativeX == "left_adjustable" )
            xFactor = -1;
        else
            xFactor = 1;
    }

    self.x = element.x + offsetX * xFactor;

    if ( maps\mp\_utility::strip_suffix( relativeY, "_adjustable" ) == element.aligny )
    {
        offsetY = 0;
        yFactor = 0;
    }
    else if ( relativeY == "middle" || element.aligny == "middle" )
    {
        offsetY = int( element.height / 2 );

        if ( relativeY == "top_adjustable" || element.aligny == "bottom" )
            yFactor = -1;
        else
            yFactor = 1;
    }
    else
    {
        offsetY = element.height;

        if ( relativeY == "top_adjustable" )
            yFactor = -1;
        else
            yFactor = 1;
    }

    self.y = element.y + offsetY * yFactor;
    self.x = self.x + self.xOffset;
    self.y = self.y + self.yOffset;

    switch ( self.elemType )
    {
        case "bar":
            setPointBar( point, relativePoint, xOffset, yOffset );
            break;
    }

    updateChildren();
}

setPointBar( point, relativePoint, xOffset, yOffset )
{
    self.bar.horzalign = self.horzalign;
    self.bar.vertalign = self.vertalign;
    self.bar.alignx = "left";
    self.bar.aligny = self.aligny;
    self.bar.y = self.y;

    if ( self.alignx == "left" )
        self.bar.x = self.x;
    else if ( self.alignx == "right" )
        self.bar.x = self.x - self.width;
    else
        self.bar.x = self.x - int( self.width / 2 );

    if ( self.aligny == "top" )
        self.bar.y = self.y;
    else if ( self.aligny == "bottom" )
        self.bar.y = self.y;

    updateBar( self.bar.frac );
}

updateBar( barFrac, rateOfChange )
{
    if ( self.elemType == "bar" )
        updateBarScale( barFrac, rateOfChange );
}

updateBarScale( barFrac, rateOfChange )
{
    barWidth = int( self.width * barFrac + 0.5 );

    if ( !barWidth )
        barWidth = 1;

    self.bar.frac = barFrac;
    self.bar setshader( self.bar.shader, barWidth, self.height );

    if ( isdefined( rateOfChange ) && barWidth < self.width )
    {
        if ( rateOfChange > 0 )
            self.bar scaleovertime( ( 1 - barFrac ) / rateOfChange, self.width, self.height );
        else if ( rateOfChange < 0 )
            self.bar scaleovertime( barFrac / -1 * rateOfChange, 1, self.height );
    }

    self.bar.rateOfChange = rateOfChange;
    self.bar.lastUpdateTime = gettime();
}

createFontString( font, fontScale )
{
    fontElem = newclienthudelem( self );
    fontElem.elemType = "font";
    fontElem.font = font;
    fontElem.fontScale = fontScale;
    fontElem.baseFontScale = fontScale;
    fontElem.x = 0;
    fontElem.y = 0;
    fontElem.width = 0;
    fontElem.height = int( level.fontHeight * fontScale );
    fontElem.xOffset = 0;
    fontElem.yOffset = 0;
    fontElem.children = [];
    fontElem setParent( level.uiParent );
    fontElem.hidden = 0;
    return fontElem;
}

createServerFontString( font, fontScale, team )
{
    if ( isdefined( team ) )
        fontElem = newteamhudelem( team );
    else
        fontElem = newhudelem();

    fontElem.elemType = "font";
    fontElem.font = font;
    fontElem.fontScale = fontScale;
    fontElem.baseFontScale = fontScale;
    fontElem.x = 0;
    fontElem.y = 0;
    fontElem.width = 0;
    fontElem.height = int( level.fontHeight * fontScale );
    fontElem.xOffset = 0;
    fontElem.yOffset = 0;
    fontElem.children = [];
    fontElem setParent( level.uiParent );
    fontElem.hidden = 0;
    return fontElem;
}

createServerTimer( font, fontScale, team )
{
    if ( isdefined( team ) )
        timerElem = newteamhudelem( team );
    else
        timerElem = newhudelem();

    timerElem.elemType = "timer";
    timerElem.font = font;
    timerElem.fontScale = fontScale;
    timerElem.baseFontScale = fontScale;
    timerElem.x = 0;
    timerElem.y = 0;
    timerElem.width = 0;
    timerElem.height = int( level.fontHeight * fontScale );
    timerElem.xOffset = 0;
    timerElem.yOffset = 0;
    timerElem.children = [];
    timerElem setParent( level.uiParent );
    timerElem.hidden = 0;
    return timerElem;
}

createTimer( font, fontScale )
{
    timerElem = newclienthudelem( self );
    timerElem.elemType = "timer";
    timerElem.font = font;
    timerElem.fontScale = fontScale;
    timerElem.baseFontScale = fontScale;
    timerElem.x = 0;
    timerElem.y = 0;
    timerElem.width = 0;
    timerElem.height = int( level.fontHeight * fontScale );
    timerElem.xOffset = 0;
    timerElem.yOffset = 0;
    timerElem.children = [];
    timerElem setParent( level.uiParent );
    timerElem.hidden = 0;
    return timerElem;
}

createIcon( shader, width, height )
{
    iconElem = newclienthudelem( self );
    iconElem.elemType = "icon";
    iconElem.x = 0;
    iconElem.y = 0;
    iconElem.width = width;
    iconElem.height = height;
    iconElem.baseWidth = iconElem.width;
    iconElem.baseHeight = iconElem.height;
    iconElem.xOffset = 0;
    iconElem.yOffset = 0;
    iconElem.children = [];
    iconElem setParent( level.uiParent );
    iconElem.hidden = 0;

    if ( isdefined( shader ) )
    {
        iconElem setshader( shader, width, height );
        iconElem.shader = shader;
    }

    return iconElem;
}

createServerIcon( shader, width, height, team )
{
    if ( isdefined( team ) )
        iconElem = newteamhudelem( team );
    else
        iconElem = newhudelem();

    iconElem.elemType = "icon";
    iconElem.x = 0;
    iconElem.y = 0;
    iconElem.width = width;
    iconElem.height = height;
    iconElem.baseWidth = iconElem.width;
    iconElem.baseHeight = iconElem.height;
    iconElem.xOffset = 0;
    iconElem.yOffset = 0;
    iconElem.children = [];
    iconElem setParent( level.uiParent );
    iconElem.hidden = 0;

    if ( isdefined( shader ) )
    {
        iconElem setshader( shader, width, height );
        iconElem.shader = shader;
    }

    return iconElem;
}

createServerBar( color, width, height, flashFrac, team, selected )
{
    if ( isdefined( team ) )
        barElem = newteamhudelem( team );
    else
        barElem = newhudelem();

    barElem.x = 0;
    barElem.y = 0;
    barElem.frac = 0;
    barElem.color = color;
    barElem.sort = -2;
    barElem.shader = "progress_bar_fill";
    barElem setshader( "progress_bar_fill", width, height );
    barElem.hidden = 0;

    if ( isdefined( flashFrac ) )
        barElem.flashFrac = flashFrac;

    if ( isdefined( team ) )
        barElemBG = newteamhudelem( team );
    else
        barElemBG = newhudelem();

    barElemBG.elemType = "bar";
    barElemBG.x = 0;
    barElemBG.y = 0;
    barElemBG.width = width;
    barElemBG.height = height;
    barElemBG.xOffset = 0;
    barElemBG.yOffset = 0;
    barElemBG.bar = barElem;
    barElemBG.children = [];
    barElemBG.sort = -3;
    barElemBG.color = ( 0, 0, 0 );
    barElemBG.alpha = 0.5;
    barElemBG setParent( level.uiParent );
    barElemBG setshader( "progress_bar_bg", width, height );
    barElemBG.hidden = 0;
    return barElemBG;
}

createBar( color, width, height, flashFrac )
{
    barElem = newclienthudelem( self );
    barElem.x = 0;
    barElem.y = 0;
    barElem.frac = 0;
    barElem.color = color;
    barElem.sort = -2;
    barElem.shader = "progress_bar_fill";
    barElem setshader( "progress_bar_fill", width, height );
    barElem.hidden = 0;

    if ( isdefined( flashFrac ) )
        barElem.flashFrac = flashFrac;

    barElemBG = newclienthudelem( self );
    barElemBG.elemType = "bar";
    barElemBG.width = width;
    barElemBG.height = height;
    barElemBG.xOffset = 0;
    barElemBG.yOffset = 0;
    barElemBG.bar = barElem;
    barElemBG.children = [];
    barElemBG.sort = -3;
    barElemBG.color = ( 0, 0, 0 );
    barElemBG.alpha = 0.5;
    barElemBG setParent( level.uiParent );
    barElemBG setshader( "progress_bar_bg", width + 4, height + 4 );
    barElemBG.hidden = 0;
    return barElemBG;
}

getCurrentFraction()
{
    frac = self.bar.frac;

    if ( isdefined( self.bar.rateOfChange ) )
    {
        frac += ( gettime() - self.bar.lastUpdateTime ) * self.bar.rateOfChange;

        if ( frac > 1 )
            frac = 1;

        if ( frac < 0 )
            frac = 0;
    }

    return frac;
}

createPrimaryProgressBar( xOffset, yOffset )
{
    if ( !isdefined( xOffset ) )
        xOffset = 0;

    if ( !isdefined( yOffset ) )
        yOffset = 0;

    if ( self issplitscreenplayer() )
        yOffset += 20;

    bar = createBar( ( 1, 1, 1 ), level.primaryProgressBarWidth, level.primaryProgressBarHeight );
    bar setPoint( "CENTER", undefined, level.primaryProgressBarX + xOffset, level.primaryProgressBarY + yOffset );
    return bar;
}

createPrimaryProgressBarText( xOffset, yOffset )
{
    if ( !isdefined( xOffset ) )
        xOffset = 0;

    if ( !isdefined( yOffset ) )
        yOffset = 0;

    if ( self issplitscreenplayer() )
        yOffset += 20;

    text = createFontString( "hudbig", level.primaryProgressBarFontSize );
    text setPoint( "CENTER", undefined, level.primaryProgressBarTextX + xOffset, level.primaryProgressBarTextY + yOffset );
    text.sort = -1;
    return text;
}

createTeamProgressBar( team )
{
    bar = createServerBar( ( 1, 0, 0 ), level.teamProgressBarWidth, level.teamProgressBarHeight, undefined, team );
    bar setPoint( "TOP", undefined, 0, level.teamProgressBarY );
    return bar;
}

createTeamProgressBarText( team )
{
    text = createServerFontString( "default", level.teamProgressBarFontSize, team );
    text setPoint( "TOP", undefined, 0, level.teamProgressBarTextY );
    return text;
}

setFlashFrac( flashFrac )
{
    self.bar.flashFrac = flashFrac;
}

hideElem()
{
    if ( self.hidden )
        return;

    self.hidden = 1;

    if ( self.alpha != 0 )
        self.alpha = 0;

    if ( self.elemType == "bar" || self.elemType == "bar_shader" )
    {
        self.bar.hidden = 1;

        if ( self.bar.alpha != 0 )
            self.bar.alpha = 0;
    }
}

showElem()
{
    if ( !self.hidden )
        return;

    self.hidden = 0;

    if ( self.elemType == "bar" || self.elemType == "bar_shader" )
    {
        if ( self.alpha != 0.5 )
            self.alpha = 0.5;

        self.bar.hidden = 0;

        if ( self.bar.alpha != 1 )
            self.bar.alpha = 1;
    }
    else if ( self.alpha != 1 )
        self.alpha = 1;
}

flashThread()
{
    self endon( "death" );

    if ( !self.hidden )
        self.alpha = 1;

    for (;;)
    {
        if ( self.frac >= self.flashFrac )
        {
            if ( !self.hidden )
            {
                self fadeovertime( 0.3 );
                self.alpha = 0.2;
                wait 0.35;
                self fadeovertime( 0.3 );
                self.alpha = 1;
            }

            wait 0.7;
            continue;
        }

        if ( !self.hidden && self.alpha != 1 )
            self.alpha = 1;

        wait 0.05;
    }
}

destroyElem()
{
    tempChildren = [];

    for ( index = 0; index < self.children.size; index++ )
    {
        if ( isdefined( self.children[index] ) )
            tempChildren[tempChildren.size] = self.children[index];
    }

    for ( index = 0; index < tempChildren.size; index++ )
        tempChildren[index] setParent( getParent() );

    if ( self.elemType == "bar" || self.elemType == "bar_shader" )
        self.bar destroy();

    self destroy();
}

setIconShader( shader )
{
    self setshader( shader, self.width, self.height );
    self.shader = shader;
}

getIconShader( shader )
{
    return self.shader;
}

setIconSize( width, height )
{
    self setshader( self.shader, width, height );
}

setWidth( width )
{
    self.width = width;
}

setHeight( height )
{
    self.height = height;
}

setSize( width, height )
{
    self.width = width;
    self.height = height;
}

updateChildren()
{
    for ( index = 0; index < self.children.size; index++ )
    {
        child = self.children[index];
        child setPoint( child.point, child.relativePoint, child.xOffset, child.yOffset );
    }
}

transitionReset()
{
    self.x = self.xOffset;
    self.y = self.yOffset;

    if ( self.elemType == "font" )
    {
        self.fontScale = self.baseFontScale;
        self.label = &"";
    }
    else if ( self.elemType == "icon" )
        self setshader( self.shader, self.width, self.height );

    self.alpha = 0;
}

transitionZoomIn( duration )
{
    switch ( self.elemType )
    {
        case "font":
        case "timer":
            self.fontScale = 6.3;
            self changefontscaleovertime( duration );
            self.fontScale = self.baseFontScale;
            break;
        case "icon":
            self setshader( self.shader, self.width * 6, self.height * 6 );
            self scaleovertime( duration, self.width, self.height );
            break;
    }
}

transitionPulseFXIn( inTime, duration )
{
    transTime = int( inTime ) * 1000;
    showTime = int( duration ) * 1000;

    switch ( self.elemType )
    {
        case "font":
        case "timer":
            self setpulsefx( transTime + 250, showTime + transTime, transTime + 250 );
            break;
        default:
            break;
    }
}

transitionSlideIn( duration, direction )
{
    if ( !isdefined( direction ) )
        direction = "left";

    switch ( direction )
    {
        case "left":
            self.x = self.x + 1000;
            break;
        case "right":
            self.x = self.x - 1000;
            break;
        case "up":
            self.y = self.y - 1000;
            break;
        case "down":
            self.y = self.y + 1000;
            break;
    }

    self moveovertime( duration );
    self.x = self.xOffset;
    self.y = self.yOffset;
}

transitionSlideOut( duration, direction )
{
    if ( !isdefined( direction ) )
        direction = "left";

    gotoX = self.xOffset;
    gotoY = self.yOffset;

    switch ( direction )
    {
        case "left":
            gotoX += 1000;
            break;
        case "right":
            gotoX -= 1000;
            break;
        case "up":
            gotoY -= 1000;
            break;
        case "down":
            gotoY += 1000;
            break;
    }

    self.alpha = 1;
    self moveovertime( duration );
    self.x = gotoX;
    self.y = gotoY;
}

transitionZoomOut( duration )
{
    switch ( self.elemType )
    {
        case "font":
        case "timer":
            self changefontscaleovertime( duration );
            self.fontScale = 6.3;
        case "icon":
            self scaleovertime( duration, self.width * 6, self.height * 6 );
            break;
    }
}

transitionFadeIn( duration )
{
    self fadeovertime( duration );

    if ( isdefined( self.maxAlpha ) )
        self.alpha = self.maxAlpha;
    else
        self.alpha = 1;
}

transitionFadeOut( duration )
{
    self fadeovertime( 0.15 );
    self.alpha = 0;
}

getWeeklyRef( chRef )
{
    for ( chIndex = 0; chIndex < 3; chIndex++ )
    {
        weeklyId = self getplayerdata( "weeklyChallengeId", chIndex );
        weeklyRef = tablelookupbyrow( "mp/weeklyChallengesTable.csv", weeklyId, 0 );

        if ( weeklyRef == chRef )
            return "ch_weekly_" + chIndex;
    }

    return "";
}

getDailyRef( chRef )
{
    for ( chIndex = 0; chIndex < 3; chIndex++ )
    {
        dailyId = self getplayerdata( "dailyChallengeId", chIndex );
        dailyRef = tablelookupbyrow( "mp/dailyChallengesTable.csv", dailyId, 0 );

        if ( dailyRef == chRef )
            return "ch_daily_" + chIndex;
    }

    return "";
}

ch_getProgress( refString )
{
    if ( level.challengeInfo[refString]["type"] == 0 )
        return self getplayerdata( "challengeProgress", refString );
    else if ( level.challengeInfo[refString]["type"] == 1 )
        return self getplayerdata( "challengeProgress", getDailyRef( refString ) );
    else if ( level.challengeInfo[refString]["type"] == 2 )
        return self getplayerdata( "challengeProgress", getWeeklyRef( refString ) );
}

ch_getState( refString )
{
    if ( level.challengeInfo[refString]["type"] == 0 )
        return self getplayerdata( "challengeState", refString );
    else if ( level.challengeInfo[refString]["type"] == 1 )
        return self getplayerdata( "challengeState", getDailyRef( refString ) );
    else if ( level.challengeInfo[refString]["type"] == 2 )
        return self getplayerdata( "challengeState", getWeeklyRef( refString ) );
}

ch_setProgress( refString, value )
{
    if ( level.challengeInfo[refString]["type"] == 0 )
        return self setplayerdata( "challengeProgress", refString, value );
    else if ( level.challengeInfo[refString]["type"] == 1 )
        return self setplayerdata( "challengeProgress", getDailyRef( refString ), value );
    else if ( level.challengeInfo[refString]["type"] == 2 )
        return self setplayerdata( "challengeProgress", getWeeklyRef( refString ), value );
}

ch_setState( refString, value )
{
    if ( level.challengeInfo[refString]["type"] == 0 )
        return self setplayerdata( "challengeState", refString, value );
    else if ( level.challengeInfo[refString]["type"] == 1 )
        return self setplayerdata( "challengeState", getDailyRef( refString ), value );
    else if ( level.challengeInfo[refString]["type"] == 2 )
        return self setplayerdata( "challengeState", getWeeklyRef( refString ), value );
}

ch_getTarget( refString, value )
{
    if ( level.challengeInfo[refString]["type"] == 0 )
        return int( tablelookup( "mp/allChallengesTable.csv", 0, refString, 6 + ( value - 1 ) * 2 ) );
    else if ( level.challengeInfo[refString]["type"] == 1 )
        return int( tablelookup( "mp/dailyChallengesTable.csv", 0, refString, 6 + ( value - 1 ) * 2 ) );
    else if ( level.challengeInfo[refString]["type"] == 2 )
        return int( tablelookup( "mp/weeklyChallengesTable.csv", 0, refString, 6 + ( value - 1 ) * 2 ) );
}
