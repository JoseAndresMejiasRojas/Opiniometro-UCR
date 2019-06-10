﻿using System;
using System.Data.Entity.Core.Objects;
using System.Text;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Opiniometro_WebApp.Models;
using System.Security.Claims;
using Microsoft.AspNet.Identity;
using Microsoft.Owin.Security;


namespace Opiniometro_WebApp.Controllers
{
    [Authorize]
    public class AdminController : Controller
    {
        private Opiniometro_DatosEntities db = new Opiniometro_DatosEntities();

        private Opiniometro_WebApp.Models.PersonaPerfilEnfasisModel modelPersona = new Opiniometro_WebApp.Models.PersonaPerfilEnfasisModel();

        public Persona Persona { get; private set; }

        public ActionResult VerPersonas(string cedula)
        {
            List<Persona> personas = db.Persona.ToList();
            var persona = from s in db.Persona
                          select s;

            if (!String.IsNullOrEmpty(cedula))
            {
                persona = persona.Where(s => s.Cedula.Contains(cedula)
                                       );
                return View(persona);
            }
            else
            {
                return View(personas);
            }

            
        }

        public ActionResult Editar(string id)
        {
            try
            {
                    modelPersona.Persona = db.Persona.Find(id);
                    return View(modelPersona);
                
            }
            catch (Exception)
            {

                throw;
            }
            
            
        }

        [HttpPost]
        public ActionResult Editar(PersonaPerfilEnfasisModel per)
        {
            try
            {
                using (db)
                {
                    db.SP_ModificarPersona(per.Persona.Cedula, per.Persona.Cedula, per.Persona.Nombre, per.Persona.Apellido1, per.Persona.Apellido2, per.Persona.Direccion);
                    return RedirectToAction("VerPersonas");
                }
            }
            catch (Exception)
            {

                throw;
            }
           
        }


        public ActionResult Borrar(string id)
        {
           // db.SP_EliminarPersona(id);
            return RedirectToAction("VerPersonas");
        }


        public ActionResult CrearUsuario()
        {
            
            return View();
        }

       /* public DataSet GetDataSet(string ConnectionString, string SQL)
        {
            
                        SqlDataAdapter da = new SqlDataAdapter();

                        cmd.CommandText = SQL;
                        da.SelectCommand = cmd;
                        DataSet ds = new DataSet();

                        conn.Open();
                        da.Fill(ds);
                        conn.Close();

                        return ds;
                    }
            DataTable table = new DataTable();
            using (var con = new SqlConnection(ConfigurationManager.ConnectionStrings["DB"].ConnectionString))
            using (var cmd = new SqlCommand("usp_GetABCD", con))
            using (var da = new SqlDataAdapter(cmd))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                da.Fill(table);
            }*/

        }
    }