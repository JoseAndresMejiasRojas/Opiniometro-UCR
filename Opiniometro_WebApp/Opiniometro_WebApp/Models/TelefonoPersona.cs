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
    
    public partial class TelefonoPersona
    {
        public string CedulaPersona { get; set; }
        public string NumeroTelefono { get; set; }
    
        public virtual Persona Persona { get; set; }
    }
}
