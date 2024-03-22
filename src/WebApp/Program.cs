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

builder.Services.AddRazorComponents().AddInteractiveServerComponents();

builder.AddApplicationServices();

var app = builder.Build();

app.MapDefaultEndpoints();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseAntiforgery();

app.UseHttpsRedirection();

app.UseStaticFiles();

app.MapRazorComponents<App>().AddInteractiveServerRenderMode();

app.MapForwarder("/product-images/{id}", "http://catalog-api", "/api/v1/catalog/items/{id}/pic");

app.Run();

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
