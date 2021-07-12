init()
{
    level thread onPlayerConnect();
}
onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  player );
        player thread onPlayerConnect();
    }
}
onPlayerSpawned()
{
    self endon( "disconnect" );
    for (;;)
    {
        self waittill( "spawned_player" );
    }
}