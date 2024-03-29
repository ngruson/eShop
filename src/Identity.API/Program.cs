using System.Net;
using Duende.IdentityServer.Hosting;
using Identity.API;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.IdentityModel.Logging;

var builder = WebApplication.CreateBuilder(args);

var configFolder = builder.Configuration.GetValue<string>("ConfigurationFolder");
bool customConfig = false;
if (!string.IsNullOrWhiteSpace(configFolder) &&
  Directory.Exists(configFolder))
{
    customConfig = true;
    builder.Configuration.AddKeyPerFile(configFolder, false, true);
}

builder.AddServiceDefaults();

builder.Services.AddControllersWithViews();

builder.AddNpgsqlDbContext<ApplicationDbContext>("identitydb");

// Apply database migration automatically. Note that this approach is not
// recommended for production scenarios. Consider generating SQL scripts from
// migrations instead.
builder.Services.AddMigration<ApplicationDbContext, UsersSeed>();

builder.Services.AddIdentity<ApplicationUser, IdentityRole>()
        .AddEntityFrameworkStores<ApplicationDbContext>()
        .AddDefaultTokenProviders();

builder.Services.AddIdentityServer(options =>
{
    options.IssuerUri = "null";
    //options.IssuerUri = builder.Configuration["IssuerUri"];
    options.Authentication.CookieLifetime = TimeSpan.FromHours(2);

    options.Events.RaiseErrorEvents = true;
    options.Events.RaiseInformationEvents = true;
    options.Events.RaiseFailureEvents = true;
    options.Events.RaiseSuccessEvents = true;

    // TODO: Remove this line in production.
    options.KeyManagement.Enabled = false;
})
.AddInMemoryIdentityResources(Config.GetResources())
.AddInMemoryApiScopes(Config.GetApiScopes())
.AddInMemoryApiResources(Config.GetApis())
.AddInMemoryClients(Config.GetClients(builder.Configuration))
.AddAspNetIdentity<ApplicationUser>()
// TODO: Not recommended for production - you need to store your key material somewhere secure
.AddDeveloperSigningCredential();

IdentityModelEventSource.ShowPII = true;

builder.Services.AddTransient<IProfileService, ProfileService>();
builder.Services.AddTransient<ILoginService<ApplicationUser>, EFLoginService>();
builder.Services.AddTransient<IRedirectService, RedirectService>();

var app = builder.Build();

//var forwardOptions = new ForwardedHeadersOptions
//{
//    ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto,
//    RequireHeaderSymmetry = false
//};
//forwardOptions.KnownNetworks.Clear();
//forwardOptions.KnownProxies.Clear();

//app.UseForwardedHeaders(forwardOptions);

//app.Use(async (context, next) =>
//{
//    context.Request.Scheme = "https";
//    context.Request.Host = new HostString("dev.myeshopdemo.com");
//    await next();
//});

app.MapDefaultEndpoints();

app.UseStaticFiles();

// This cookie policy fixes login issues with Chrome 80+ using HTTP
app.UseCookiePolicy(new CookiePolicyOptions { MinimumSameSitePolicy = SameSiteMode.Lax });
app.UseRouting();
app.UseIdentityServer();
app.UseMiddleware<IngressMiddleware>();
app.UseAuthorization();

app.MapDefaultControllerRoute();

if (customConfig)
{
    var logger = app.Services.GetRequiredService<ILogger<Program>>();
    logger.LogInformation("Using custom configuration from {configFolder}", configFolder);
}
else
{
    var logger = app.Services.GetRequiredService<ILogger<Program>>();
    logger.LogInformation("NOT using custom configuration from {configFolder}", configFolder);
}

app.Run();
