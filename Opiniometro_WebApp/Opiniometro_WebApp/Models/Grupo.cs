//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Opiniometro_WebApp.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class Grupo
    {
        public byte Numero { get; set; }
        public string SiglaCurso { get; set; }
        public string Año { get; set; }
        public byte Semestre { get; set; }
    
        public virtual Ciclo_Lectivo Ciclo_Lectivo { get; set; }
        public virtual Curso Curso { get; set; }
    }
}