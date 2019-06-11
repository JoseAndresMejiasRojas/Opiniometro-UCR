﻿using System;
using System.Web;
using System.Web.Mvc;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;
using Opiniometro_WebApp.Controllers;
using Opiniometro_WebApp.Controllers.Servicios;

namespace Opiniometro_WebAppTest.Controllers
{
    [TestClass]
    public class HomeControllerTest
    {
        [TestMethod]
        public void TestHomeNotNullLoginFallido()
        {
            // Mocks necesarios para tener una sesion "de mentira".
            var mock_controller_contexto = new Mock<ControllerContext>();
            var mock_session = new Mock<HttpSessionStateBase>();
            mock_session.SetupGet(s => s["login_fallido"]).Returns(null); //somevalue
            mock_controller_contexto.Setup(p => p.HttpContext.Session).Returns(mock_session.Object);

            var controller = new HomeController();

            // Agrego los mocks al contexto del controlador.
            controller.ControllerContext = mock_controller_contexto.Object;
            var result = controller.Index() as ActionResult;

            Assert.IsNotNull(result);
        }
    }
}