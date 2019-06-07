﻿ using System;
using System.IO;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Net.Mime;
using System.Web;
using System.Web.Mvc;
using Opiniometro_WebApp.Models;
using Microsoft.SqlServer.Dts;
using Microsoft.SqlServer.Dts.Runtime;


namespace Opiniometro_WebApp.Controllers
{
    public class AdministradorController : Controller
    {
        private Opiniometro_DatosEntities db = new Opiniometro_DatosEntities();

        // GET: Administrador
        public ActionResult Index()
        {
            
            return View();
        }

       
        [HttpGet]
        public ActionResult CargarArchivo()
        {
            return View();
        }

        [HttpPost]
        public ActionResult CargarArchivo(HttpPostedFileBase postedFile)
        {
            if (postedFile != null && postedFile.ContentLength > 0)
            {
                if (postedFile.FileName.EndsWith(".csv"))
                {
                    string path = Server.MapPath("~/App_Data/ArchivosCargados/");
                    if (!Directory.Exists(path))
                    {
                        Directory.CreateDirectory(path);
                    }

                    postedFile.SaveAs(path + Path.GetFileName(postedFile.FileName));
                    ViewBag.Message = "File uploaded successfully.";
                    
                }
                else
                {
                    ViewBag.Message = "Error, este formato de archivo no es compatible";
                }
                
            }


            //Codigo para procesamiento de archivo por ssis

            //Invocar paquete de intregracion, pasar como parametro el nombre del archivo cargado.

            //Application app = new Application()
            

            return View();
        }
    }
}
