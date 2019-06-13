﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using Opiniometro_WebApp.Models;
using System.Data.Entity.Core.Objects;
using System.Web.Helpers; //Para graficos, borrar despues

namespace Opiniometro_WebApp.Controllers
{
    public class VisualizarFormularioController : Controller
    {
        private Opiniometro_DatosEntities db = new Opiniometro_DatosEntities();

        // GET: VisualizarFormulario
        public ActionResult Index()
        {
            return View(db.Formulario.ToList());
        }

        // GET: VisualizarFormulario/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Formulario formulario = db.Formulario.Find(id);
            if (formulario == null)
            {
                return HttpNotFound();
            }
            return View(formulario);
        }

        // GET: VisualizarFormulario/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: VisualizarFormulario/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "CodigoFormulario,Nombre")] Formulario formulario)
        {
            if (ModelState.IsValid)
            {
                db.Formulario.Add(formulario);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            return View(formulario);
        }

        // GET: VisualizarFormulario/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Formulario formulario = db.Formulario.Find(id);
            if (formulario == null)
            {
                return HttpNotFound();
            }
            return View(formulario);
        }

        // POST: VisualizarFormulario/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "CodigoFormulario,Nombre")] Formulario formulario)
        {
            if (ModelState.IsValid)
            {
                db.Entry(formulario).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            return View(formulario);
        }

        // GET: VisualizarFormulario/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Formulario formulario = db.Formulario.Find(id);
            if (formulario == null)
            {
                return HttpNotFound();
            }
            return View(formulario);
        }

        // POST: VisualizarFormulario/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            Formulario formulario = db.Formulario.Find(id);
            db.Formulario.Remove(formulario);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }

        //EFE: Devuelve un Int con la cantidad de respuestas por respuesta.
        //REQ: Que exista la conexion a la base de datos.
        //MOD:--
        [HttpGet]
        private ObjectResult<SP_ContarRespuestasPorGrupo_Result> ObtenerCantidadRespuestasPorPregunta(string codigoFormulario, string cedulaProfesor, short? annoGrupo, byte? semestreGrupo, byte? numeroGrupo, string siglaCurso, string itemId)
        {
            var result = db.SP_ContarRespuestasPorGrupo(codigoFormulario, cedulaProfesor, annoGrupo, semestreGrupo, numeroGrupo, siglaCurso, itemId);
            return result;
        }

        //EFE:Crea un gráfico con la información de los resultados en la base de datos.
        //REQ:Que exista una conexion a la base de datos.
        //MOD:--
        public JsonResult GraficoPie(string itemId)
        {
            var result = ObtenerCantidadRespuestasPorPregunta("131313", "100000002", 2017, 2, 1, "CI1330", itemId).ToList();//ObtenerCantidadRespuestasPorPregunta  "PRE303"
            //int tamanio = result.Count;
            List<object> x = new List<object>();
            List<object> y = new List<object>();
            //string[] leyenda = new string[tamanio];
            //int?[] cntResps = new int?[tamanio];
            //int iter = 0;
            foreach (var itemR in result)
            {
                //leyenda[iter] = itemR.Respuesta;
                //cntResps[iter] = itemR.cntResp;
                //iter++;
                x.Add(itemR.Respuesta);
                y.Add(itemR.cntResp);
            }
            List<object> lista = new List<object> { x, y };
            return Json(lista, JsonRequestBehavior.AllowGet);
        }
    }
}
