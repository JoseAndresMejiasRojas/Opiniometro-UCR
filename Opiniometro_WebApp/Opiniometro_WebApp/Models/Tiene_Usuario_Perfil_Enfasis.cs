//------------------------------------------------------------------------------
// <auto-generated>
//     Este código se generó a partir de una plantilla.
//
//     Los cambios manuales en este archivo pueden causar un comportamiento inesperado de la aplicación.
//     Los cambios manuales en este archivo se sobrescribirán si se regenera el código.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Opiniometro_WebApp.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class Tiene_Usuario_Perfil_Enfasis
    {
        public string CorreoInstitucional { get; set; }
        public byte NumeroEnfasis { get; set; }
        public string SiglaCarrera { get; set; }
        public string NombrePerfil { get; set; }
    
        public virtual Enfasis Enfasis { get; set; }
        public virtual Perfil Perfil { get; set; }
        public virtual Usuario Usuario { get; set; }
    }
}
