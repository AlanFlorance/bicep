// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Diagnostics.CodeAnalysis;
using Bicep.Core.Diagnostics;
using Bicep.Core.Emit;
using Bicep.Core.PrettyPrintV2;
using Bicep.Core.UnitTests;
using Bicep.Core.UnitTests.Assertions;
using Bicep.Core.UnitTests.Baselines;
using Bicep.Core.UnitTests.Features;
using Bicep.Core.UnitTests.Utils;
using FluentAssertions;
using FluentAssertions.Execution;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Bicep.Core.IntegrationTests
{
    [TestClass]
    public class ExamplesTests
    {
        private static ServiceBuilder Services => new ServiceBuilder().WithDisabledAnalyzersConfiguration();

        [NotNull]
        public TestContext? TestContext { get; set; }

        public static async Task RunExampleTest(TestContext testContext, EmbeddedFile embeddedBicep, FeatureProviderOverrides? features = null, string jsonFileExtension = ".json")
        {
            features ??= new();
            var baselineFolder = BaselineFolder.BuildOutputFolder(testContext, embeddedBicep);
            var bicepFile = baselineFolder.EntryFile;
            var jsonFile = baselineFolder.GetFileOrEnsureCheckedIn(Path.ChangeExtension(embeddedBicep.FileName, jsonFileExtension));

            var compiler = Services.WithFeatureOverrides(features).Build().GetCompiler();
            var compilation = await compiler.CreateCompilation(bicepFile.OutputFileUri);
            var model = compilation.GetEntrypointSemanticModel();

            var emitter = new TemplateEmitter(model);

            foreach (var (file, diagnostics) in compilation.GetAllDiagnosticsByBicepFile())
            {
                DiagnosticAssertions.DoWithDiagnosticAnnotations(
                    file,
                    diagnostics.Where(d => !IsPermittedMissingTypeDiagnostic(d)),
                    diagnostics =>
                    {
                        diagnostics.Should().BeEmpty("{0} should not have warnings or errors", file.FileHandle.Uri);
                    });
            }

            // group assertion failures using AssertionScope, rather than reporting the first failure
            using (new AssertionScope())
            {
                var stringWriter = new StringWriter();
                var result = emitter.Emit(stringWriter);

                result.Status.Should().Be(EmitStatus.Succeeded);

                if (result.Status == EmitStatus.Succeeded)
                {
                    jsonFile.WriteToOutputFolder(stringWriter.ToString());
                    jsonFile.ShouldHaveExpectedJsonValue();

                    // validate that the template is parseable by the deployment engine
                    UnitTests.Utils.TemplateHelper.TemplateShouldBeValid(stringWriter.ToString(), model.Features);
                }
            }
        }

        [DataTestMethod]
        [DynamicData(nameof(GetAllExampleData), DynamicDataSourceType.Method)]
        [TestCategory(BaselineHelper.BaselineTestCategory)]
        public Task ExampleIsValid(EmbeddedFile embeddedBicep)
            => RunExampleTest(TestContext, embeddedBicep, new(), ".json");

        [DataTestMethod]
        [DynamicData(nameof(GetAllExampleData), DynamicDataSourceType.Method)]
        [TestCategory(BaselineHelper.BaselineTestCategory)]
        public Task ExampleIsValid_using_experimental_symbolic_names(EmbeddedFile embeddedBicep)
            => RunExampleTest(TestContext, embeddedBicep, new(SymbolicNameCodegenEnabled: true), ".symbolicnames.json");

        [DataTestMethod]
        [DynamicData(nameof(GetAllExampleData), DynamicDataSourceType.Method)]
        [TestCategory(BaselineHelper.BaselineTestCategory)]
        public void Example_uses_consistent_formatting(EmbeddedFile embeddedBicep)
        {
            var baselineFolder = BaselineFolder.BuildOutputFolder(TestContext, embeddedBicep);
            var bicepFile = baselineFolder.EntryFile;

            var program = ParserHelper.Parse(embeddedBicep.Contents, out var lexingErrorLookup, out var parsingErrorLookup);
            var context = PrettyPrinterV2Context.Create(PrettyPrinterV2Options.Default, lexingErrorLookup, parsingErrorLookup);
            var formattedContents = PrettyPrinterV2.Print(program, context);
            formattedContents.Should().NotBeNull();

            bicepFile.WriteToOutputFolder(formattedContents);
            bicepFile.ShouldHaveExpectedValue();
        }

        [TestMethod]
        public void ExampleData_should_return_a_number_of_records()
        {
            GetAllExampleData().Should().HaveCountGreaterOrEqualTo(30, "sanity check to ensure we're finding examples to test");
        }

        private static IEnumerable<object[]> GetAllExampleData()
            => ExampleData.GetAllExampleData().Select(x => new object[] { x.BicepFile });

        private static bool IsPermittedMissingTypeDiagnostic(IDiagnostic diagnostic)
        {
            if (diagnostic.Code != "BCP081")
            {
                return false;
            }

            var permittedMissingTypeDiagnostics = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                // To exclude a particular type for BCP081 (if there are missing types), add an entry of format:
                // "Resource type \"<type>\" does not have types available. Bicep is unable to validate resource properties prior to deployment, but this will not block the resource from being deployed.",
            };

            return permittedMissingTypeDiagnostics.Contains(diagnostic.Message);
        }

        public record ExampleData(
            EmbeddedFile BicepFile)
        {
            public static IEnumerable<ExampleData> GetAllExampleData()
            {
                var embeddedFiles = EmbeddedFile.LoadAll(
                    typeof(Bicep.Core.Samples.AssemblyInitializer).Assembly,
                    "user_submitted",
                    streamName => Path.GetExtension(streamName) == ".bicep");

                foreach (var bicepFile in embeddedFiles)
                {
                    yield return new ExampleData(bicepFile);
                }
            }
        }
    }
}
