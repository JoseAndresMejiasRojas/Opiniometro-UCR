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
    
    public partial class Escalar
    {
        public string ItemId { get; set; }
        public short Inicio { get; set; }
        public short Fin { get; set; }
        public Nullable<bool> IsaEstrella { get; set; }
    
        public virtual Item Item { get; set; }
    }
}
