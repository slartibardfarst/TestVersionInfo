using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TestVersionInfo
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
            this.label2.Text = Assembly.GetExecutingAssembly().GetName().Version.ToString();
        }
    }
}
